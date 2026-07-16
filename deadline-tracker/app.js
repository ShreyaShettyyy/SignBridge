document.addEventListener('DOMContentLoaded', () => {
    // 1. Initial State & Defaults
    let deadlines = [];
    let activeFilter = 'all';

    try {
        const saved = localStorage.getItem('standalone_deadlines');
        let parsed = saved ? JSON.parse(saved) : null;

        // Force a reset if the saved data contains old subjects (Mathematics, English, Computer Science)
        const hasOldSubjects = parsed && parsed.some(dl => 
            dl.subject === 'Computer Science' || 
            dl.subject === 'Mathematics' || 
            dl.subject === 'English'
        );

        if (parsed && !hasOldSubjects) {
            // Migration check: convert completed boolean to progress percentage
            deadlines = parsed.map(dl => {
                if (dl.progress === undefined) {
                    dl.progress = dl.completed ? 100 : 0;
                    delete dl.completed;
                }
                return dl;
            });
            saveDeadlines();
        } else {
            // Load beautiful mock defaults using the updated subjects list
            deadlines = [
                { id: 'dl-mock-1', name: 'Machine Learning Classification Lab', subject: 'Machine Learning', dueDate: new Date(Date.now() + 1000 * 60 * 60 * 18).toISOString(), progress: 60 },
                { id: 'dl-mock-2', name: 'Binary Search Tree Implementation', subject: 'Data Structures with Algorithms', dueDate: new Date(Date.now() + 1000 * 60 * 60 * 48).toISOString(), progress: 10 },
                { id: 'dl-mock-3', name: 'Software Architecture Design Draft', subject: 'Software Engineering', dueDate: new Date(Date.now() + 1000 * 60 * 60 * 120).toISOString(), progress: 0 }
            ];
            saveDeadlines();
        }
    } catch (e) {
        console.error("Failed to load deadlines from localStorage:", e);
        deadlines = [];
    }

    // 2. DOM Elements
    const form = document.getElementById('deadline-form');
    const assignNameInput = document.getElementById('assign-name');
    const assignSubjectInput = document.getElementById('assign-subject');
    const assignDueInput = document.getElementById('assign-due');
    const assignProgressInput = document.getElementById('assign-progress');
    const formProgressValEl = document.getElementById('form-progress-val');
    const deadlineListContainer = document.getElementById('deadline-list');
    const filterButtons = document.querySelectorAll('.filter-btn');

    const statUrgentEl = document.getElementById('stat-urgent');
    const statPendingEl = document.getElementById('stat-pending');
    const statCompletedEl = document.getElementById('stat-completed');
    const statOverallProgressEl = document.getElementById('stat-overall-progress');
    const statOverallProgressBarEl = document.getElementById('stat-overall-progress-bar');

    // Update form progress label
    assignProgressInput.addEventListener('input', (e) => {
        formProgressValEl.textContent = `${e.target.value}%`;
    });

    // Set default datetime picker to tomorrow at 12:00 PM for easy input
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    tomorrow.setHours(12, 0, 0, 0);
    
    // Format to yyyy-MM-ddThh:mm
    const year = tomorrow.getFullYear();
    const month = String(tomorrow.getMonth() + 1).padStart(2, '0');
    const day = String(tomorrow.getDate()).padStart(2, '0');
    const hours = String(tomorrow.getHours()).padStart(2, '0');
    const minutes = String(tomorrow.getMinutes()).padStart(2, '0');
    assignDueInput.value = `${year}-${month}-${day}T${hours}:${minutes}`;

    // 3. Helper Logic
    function saveDeadlines() {
        localStorage.setItem('standalone_deadlines', JSON.stringify(deadlines));
    }

    function getUrgencyStatus(dueDateStr, progress) {
        if (progress === 100) {
            return { label: 'Completed', colorClass: 'badge-completed-status', icon: 'check-square' };
        }
        const dueTime = new Date(dueDateStr).getTime();
        const now = Date.now();
        const diffMs = dueTime - now;
        const diffHours = diffMs / (1000 * 60 * 60);

        if (diffMs <= 0) {
            return { label: 'Overdue', colorClass: 'badge-overdue', icon: 'alert-triangle' };
        } else if (diffHours <= 24) {
            return { label: 'Urgent (<24h)', colorClass: 'badge-high', icon: 'alert-triangle' };
        } else if (diffHours <= 72) {
            return { label: 'Due Soon (<3d)', colorClass: 'badge-medium', icon: 'clock' };
        } else {
            return { label: 'Low Urgency', colorClass: 'badge-low', icon: 'calendar' };
        }
    }

    function getFormattedTimeRemaining(dueDateStr) {
        const dueTime = new Date(dueDateStr).getTime();
        const now = Date.now();
        const diffMs = dueTime - now;
        const isPast = diffMs < 0;
        const absDiff = Math.abs(diffMs);

        const minutes = Math.floor(absDiff / (1000 * 60));
        const hours = Math.floor(minutes / 60);
        const days = Math.floor(hours / 24);

        if (isPast) {
            if (days > 0) return `Overdue by ${days}d ${hours % 24}h`;
            if (hours > 0) return `Overdue by ${hours}h ${minutes % 60}m`;
            return `Overdue by ${minutes}m`;
        } else {
            if (days > 0) return `${days}d ${hours % 24}h left`;
            if (hours > 0) return `${hours}h ${minutes % 60}m left`;
            return `${minutes}m left`;
        }
    }

    // 4. Render Engine
    function render() {
        // Update stats
        let urgentCount = 0;
        let pendingCount = 0;
        let completedCount = 0;
        let progressSum = 0;

        deadlines.forEach(dl => {
            progressSum += dl.progress;
            if (dl.progress === 100) {
                completedCount++;
            } else {
                pendingCount++;
                const status = getUrgencyStatus(dl.dueDate, dl.progress);
                if (status.label === 'Overdue' || status.label.startsWith('Urgent')) {
                    urgentCount++;
                }
            }
        });

        statUrgentEl.textContent = urgentCount;
        statPendingEl.textContent = pendingCount;
        statCompletedEl.textContent = completedCount;

        // Overall progress calculations
        const overallProgress = deadlines.length > 0 ? Math.round(progressSum / deadlines.length) : 0;
        statOverallProgressEl.textContent = `${overallProgress}%`;
        statOverallProgressBarEl.style.width = `${overallProgress}%`;

        // Filter & Sort
        const filtered = deadlines.filter(dl => {
            if (activeFilter === 'pending') return dl.progress < 100;
            if (activeFilter === 'in-progress') return dl.progress > 0 && dl.progress < 100;
            if (activeFilter === 'completed') return dl.progress === 100;
            return true;
        }).sort((a, b) => new Date(a.dueDate).getTime() - new Date(b.dueDate).getTime());

        // Empty state check
        if (filtered.length === 0) {
            deadlineListContainer.innerHTML = `
                <div class="no-deadlines-prompt">
                    <i data-lucide="alert-circle"></i>
                    <p style="font-weight: 600; margin-top: 8px;">No deadlines found</p>
                    <p style="font-size: 11px; margin-top: 2px;">Try selecting another filter or schedule a new task.</p>
                </div>
            `;
            lucide.createIcons();
            return;
        }

        // Render Cards
        deadlineListContainer.innerHTML = '';
        filtered.forEach(dl => {
            const status = getUrgencyStatus(dl.dueDate, dl.progress);
            const countdown = getFormattedTimeRemaining(dl.dueDate);
            const formattedDate = new Date(dl.dueDate).toLocaleString([], {
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
            const isCompleted = dl.progress === 100;

            const card = document.createElement('div');
            card.className = `deadline-item glass-panel ${isCompleted ? 'completed-task' : ''}`;
            card.dataset.id = dl.id;

            card.innerHTML = `
                <div class="deadline-main-info" style="flex-grow: 1;">
                    <button class="deadline-checkbox ${isCompleted ? 'checked' : ''}" title="${isCompleted ? 'Mark incomplete' : 'Mark completed'}">
                        <i data-lucide="${isCompleted ? 'check-square' : 'square'}"></i>
                    </button>
                    <div class="deadline-details" style="flex-grow: 1; margin-right: 20px;">
                        <h3 class="deadline-title">${escapeHTML(dl.name)}</h3>
                        <div class="deadline-meta-row">
                            <span class="deadline-subject">${escapeHTML(dl.subject)}</span>
                            <span class="deadline-date-text">
                                <i data-lucide="clock"></i>
                                Due: ${formattedDate}
                            </span>
                        </div>
                        
                        <!-- Progress Slider & Bar -->
                        <div class="card-progress-container">
                            <div class="card-progress-bar-bg">
                                <div class="card-progress-bar-fill" style="width: ${dl.progress}%;"></div>
                            </div>
                            <div class="card-progress-controls">
                                <input 
                                    type="range" 
                                    min="0" 
                                    max="100" 
                                    step="10" 
                                    value="${dl.progress}" 
                                    class="card-progress-slider"
                                    title="Drag to change completion progress"
                                >
                                <span class="card-progress-text">${dl.progress}% Complete</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="deadline-actions-cell" style="flex-shrink: 0;">
                    <div style="display: flex; flex-direction: column; align-items: flex-end; gap: 6px;">
                        <span class="badge-urgency ${status.colorClass}">
                            <i data-lucide="${status.icon}"></i>
                            ${status.label}
                        </span>
                        ${!isCompleted ? `<span style="font-size: 11px; color: var(--text-muted); font-weight: 700;">(${countdown})</span>` : ''}
                    </div>
                    <button class="btn-control btn-delete" title="Delete Deadline">
                        <i data-lucide="trash-2"></i>
                    </button>
                </div>
            `;

            // Attach Action Listeners
            const checkbox = card.querySelector('.deadline-checkbox');
            checkbox.addEventListener('click', () => {
                if (dl.progress === 100) {
                    dl.progress = 0;
                } else {
                    dl.progress = 100;
                }
                saveDeadlines();
                render();
            });

            const slider = card.querySelector('.card-progress-slider');
            slider.addEventListener('input', (e) => {
                const val = parseInt(e.target.value);
                dl.progress = val;
                
                // Update fill bar and label in real time for ultra-smooth rendering
                const fillBar = card.querySelector('.card-progress-bar-fill');
                const progressText = card.querySelector('.card-progress-text');
                
                fillBar.style.width = `${val}%`;
                progressText.textContent = `${val}% Complete`;
                
                // Toggle card completed state locally
                if (val === 100) {
                    card.classList.add('completed-task');
                    checkbox.classList.add('checked');
                } else {
                    card.classList.remove('completed-task');
                    checkbox.classList.remove('checked');
                }
            });

            // Refresh counts and save on mouse up (drag end)
            slider.addEventListener('change', () => {
                saveDeadlines();
                render();
            });

            const deleteBtn = card.querySelector('.btn-delete');
            deleteBtn.addEventListener('click', () => {
                if (confirm(`Are you sure you want to delete "${dl.name}"?`)) {
                    deadlines = deadlines.filter(item => item.id !== dl.id);
                    saveDeadlines();
                    render();
                }
            });

            deadlineListContainer.appendChild(card);
        });

        // Initialize Lucide Icons inside the new cards
        lucide.createIcons();
    }

    function escapeHTML(str) {
        return str
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // 5. Event Listeners
    // Form submission
    form.addEventListener('submit', (e) => {
        e.preventDefault();
        
        const name = assignNameInput.value.trim();
        const subject = assignSubjectInput.value;
        const dueDate = assignDueInput.value;
        const startProgress = parseInt(assignProgressInput.value);

        if (!name || !dueDate) return;

        const newDeadline = {
            id: 'dl-' + Date.now(),
            name: name,
            subject: subject,
            dueDate: new Date(dueDate).toISOString(),
            progress: startProgress
        };

        deadlines.push(newDeadline);
        saveDeadlines();
        
        // Reset name and slider, keeping subject choice
        assignNameInput.value = '';
        assignProgressInput.value = 0;
        formProgressValEl.textContent = '0%';
        render();
    });

    // Filtering Tabs
    filterButtons.forEach(btn => {
        btn.addEventListener('click', () => {
            filterButtons.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            activeFilter = btn.dataset.filter;
            render();
        });
    });

    // 6. Time Updater Loop (updates countdowns every 30 seconds)
    setInterval(() => {
        // Only rerender if there are active pending deadlines, to save cycles
        const hasPending = deadlines.some(dl => dl.progress < 100);
        if (hasPending) {
            render();
        }
    }, 30000);

    // Initial render
    render();
    lucide.createIcons();
});
