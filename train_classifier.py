import pickle
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import numpy as np


try:
    data_dict = pickle.load(open('./data.pickle', 'rb'))
except FileNotFoundError:
    print("Error: 'data.pickle' not found. Please run create_dataset.py first!")
    exit()


data = np.asarray(data_dict['data'])
labels = np.asarray(data_dict['labels'])


x_train, x_test, y_train, y_test = train_test_split(
    data, labels, test_size=0.2, shuffle=True, stratify=labels
)


model = RandomForestClassifier()
model.fit(x_train, y_train)


y_predict = model.predict(x_test)
score = accuracy_score(y_predict, y_test)

print(f'{score * 100}% of samples were classified correctly!')


f = open('model.p', 'wb')
pickle.dump({'model': model}, f)
f.close()
print("Success: model.p has been created!")

# Export compact JSON dataset for browser k-NN
import json

labels_dict = {
    '0': 'A', '1': 'B', '2': 'C', '3': 'D', '4': 'E', '5': 'F', '6': 'G', '7': 'H', '8': 'I', '9': 'J',
    '10': 'K', '11': 'L', '12': 'M', '13': 'N', '14': 'O', '15': 'P', '16': 'Q', '17': 'R', '18': 'S',
    '19': 'T', '20': 'U', '21': 'V', '22': 'W', '23': 'X', '24': 'Y', '25': 'Z',
    '26': '1', '27': '2', '28': '3', '29': '4', '30': '5', '31': '6', '32': '7', '33': '8', '34': '9', '35': '10'
}

grouped_data = {}
for feat, lbl in zip(data_dict['data'], data_dict['labels']):
    char_label = labels_dict.get(str(lbl), str(lbl))
    if char_label not in grouped_data:
        grouped_data[char_label] = []
    grouped_data[char_label].append(feat)

compact_dataset = []
for label, feats in grouped_data.items():
    n_samples = len(feats)
    step = max(1, n_samples // 100)
    subsample = feats[::step][:100]
    for feat in subsample:
        compact_dataset.append({
            'label': label,
            'features': [round(x, 4) for x in feat]
        })

with open('pretrained_dataset.json', 'w') as f_json:
    json.dump(compact_dataset, f_json)
print("Success: pretrained_dataset.json has been created for the web dashboard!")