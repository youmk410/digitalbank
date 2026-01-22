from flask import Flask, request, jsonify
import pickle
import pandas as pd

app = Flask(__name__)

with open('fraud_model.pkl', 'rb') as f:
    model = pickle.load(f)

FEATURES = ['amount', 'hour_of_day', 'day_of_week', 'cat_code', 'loc_code']

@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    try:
        row = {k: data.get(k, 0) for k in FEATURES}
        df_input = pd.DataFrame([row], columns=FEATURES)
        df_input = df_input.astype({'amount': float, 'hour_of_day': int, 'day_of_week': int, 'cat_code': int, 'loc_code': int})
    except Exception as e:
        return jsonify({'error': str(e)}), 400

    pred = int(model.predict(df_input)[0])
    proba = None
    if hasattr(model, 'predict_proba'):
        proba = float(model.predict_proba(df_input)[0, 1])

    # utile pour debug dans la console du serveur
    print("INPUT:", row, "PRED:", pred, "PROBA:", proba)

    return jsonify({'is_fraud': pred, 'probability': proba})

if __name__ == '__main__':
    app.run(debug=True)