// src/synonyms.js
// Mapping of input word (lower‑case) → array of synonyms that have image files
// Add or edit entries as needed – just keep the same structure.

const SYNONYMS = {
  // -------------------------------------------------
  // Basic synonyms (example: “pain” can be shown as “hurt”, etc.)
  // -------------------------------------------------
  pain: ["pain", "hurt", "ache", "sore", "discomfort", "agony"],

  // -------------------------------------------------
  // Agreement / Disagreement
  // -------------------------------------------------
  agree: ["ok", "fine", "yes", "yeah", "yep", "sure", "alright", "okay"],
  disagree: ["no", "nah", "nope", "not really", "don't think so", "negative"],

  // -------------------------------------------------
  // General actions & states
  // -------------------------------------------------
  "all done": ["done", "finished", "all set", "completed", "that's it", "no more"],
  help: ["help", "assist", "support", "aid", "need help", "can you help"],
  more: ["more", "again", "another", "repeat", "keep going", "continue"],
  bye: ["bye", "goodbye", "see you", "later", "farewell", "take care"],
  "call me": ["call me", "contact me", "reach out", "get in touch", "phone me"],
  clap: ["clap", "applause", "cheer", "well done", "good job", "bravo"],
  clean: ["clean", "tidy", "neat", "organize", "straighten up", "declutter"],

  // -------------------------------------------------
  // Food & drink
  // -------------------------------------------------
  eat: ["eat", "food", "hungry", "meal", "snack", "dinner", "lunch", "breakfast"],
  drink: ["drink", "thirsty", "beverage", "water", "juice", "soda", "tea", "coffee"],
  water: ["water", "H2O", "aqua", "drink", "thirsty", "hydration"],

  // -------------------------------------------------
  // Family
  // -------------------------------------------------
  dad: ["dad", "father", "papa", "daddy", "pop", "pa"],
  mom: ["mom", "mother", "mama", "mommy", "ma", "mum"],

  // -------------------------------------------------
  // Navigation / control
  // -------------------------------------------------
  go: ["go", "move", "walk", "run", "leave", "proceed", "start"],
  stop: ["stop", "halt", "pause", "wait", "freeze", "hold on"],
  "good luck": ["good luck", "best of luck", "break a leg", "fingers crossed", "wish you well"],

  // -------------------------------------------------
  // Politeness & gratitude
  // -------------------------------------------------
  sorry: ["sorry", "apologize", "my bad", "excuse me", "pardon me", "forgive me"],
  "thank you": ["thank you", "thanks", "much appreciated", "grateful", "thankful", "thanks a lot"],
  gratitude: ["gratitude", "appreciation", "thankfulness", "gratefulness", "recognition", "acknowledgment"],

  // -------------------------------------------------
  // Social / greetings
  // -------------------------------------------------
  "hand shake": ["handshake", "greeting", "salutation", "introduce", "meet"],
  how: ["how", "in what way", "by what means", "explain", "describe"],
  why: ["why", "for what reason", "what's the purpose", "explain", "justify"],
  when: ["when", "at what time", "on what date", "schedule", "timing"],
  where: ["where", "in what place", "location", "address", "spot"],
  "i love you": [
    "i love you",
    "love you",
    "i care about you",
    "i adore you",
    "i cherish you",
    "i am fond of you"
  ],
  love: ["love", "affection", "fondness", "adore", "cherish", "care for"],

  // -------------------------------------------------
  // Acceptance / decisions
  // -------------------------------------------------
  accept: ["accept", "agree", "approve", "consent", "embrace", "welcome"],
  less: ["less", "fewer", "not as much", "reduce", "decrease", "minimize"],
  move: ["move", "go", "walk", "run", "relocate", "change position"],

  // -------------------------------------------------
  // Personal pronouns / identification
  // -------------------------------------------------
  my: ["my", "mine", "belonging to me", "of me", "I have", "I own","me"],
  name: [
    "name",
    "what's your name",
    "who are you",
    "identify yourself",
    "introduce yourself"
  ],

  // -------------------------------------------------
  // Negatives / refusals
  // -------------------------------------------------
  no: ["no", "nah", "nope", "not really", "don't think so", "negative"],

  // -------------------------------------------------
  // Access & opening
  // -------------------------------------------------
  open: ["open", "uncover", "reveal", "unlock", "expose", "access"],

  // -------------------------------------------------
  // Peace & calm
  // -------------------------------------------------
  peace: ["peace", "calm", "serenity", "tranquility", "harmony", "quiet", "victory"],

  // -------------------------------------------------
  // Polite requests
  // -------------------------------------------------
  please: ["please", "kindly", "would you", "could you", "may I", "I would like"],

  // -------------------------------------------------
  // Questions / information
  // -------------------------------------------------
  question: ["question", "ask", "inquire", "query", "what's up", "can you tell me", "doubt"],

  // -------------------------------------------------
  // Show / display
  // -------------------------------------------------
  show: ["show", "display", "present", "reveal", "exhibit", "demonstrate"],
  "show me": [
    "show me",
    "display for me",
    "present to me",
    "reveal to me",
    "exhibit for me",
    "demonstrate to me"
  ],

  // -------------------------------------------------
  // Seating
  // -------------------------------------------------
  sit: ["sit", "take a seat", "rest", "perch", "settle down", "plop down"],

  // -------------------------------------------------
  // Restroom
  // -------------------------------------------------
  toilet: ["toilet", "bathroom", "restroom", "loo", "washroom", "john"],

  // -------------------------------------------------
  // General inquiry
  // -------------------------------------------------
  what: [
    "what",
    "what's",
    "what is",
    "what are",
    "what do you",
    "what can you",
    "what's up"
  ],

  // -------------------------------------------------
  // Confirmation
  // -------------------------------------------------
  yes: ["yes", "yeah", "yep", "sure", "alright", "okay", "definitely"],

  // -------------------------------------------------
  // Welcome
  // -------------------------------------------------
  welcome: ["welcome", "greeting", "salutation", "introduce", "meet", "hello"],
  YOU: ["you", "yourself", "yours", "thee", "thou", "ya","you're"]
};

// Export the map so it can be imported in App.jsx
export default SYNONYMS;