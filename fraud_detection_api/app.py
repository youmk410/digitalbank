from flask import Flask, request, jsonify
import pickle
import pandas as pd

app = Flask(__name__)

with open('fraud_model.pkl', 'rb') as f:
    model = pickle.load(f)

FEATURES = ['amount', 'hour_of_day', 'day_of_week', 'cat_code', 'loc_code']

@app.route('/', methods=['GET'])
def home():
    return render_template('home.html')

@app.route('/dashboard', methods=['GET'])
def dashboard():
    return render_template('dashboard.html')

@app.route('/admin', methods=['GET'])
def admin():
    return render_template('admin.html')

@app.route('/reports', methods=['GET'])
def reports():
    return render_template('reports.html')

@app.route('/alerts', methods=['GET'])
def alerts():
    return render_template('alerts.html')

@app.route('/logs', methods=['GET'])
def logs():
    return render_template('logs.html')

@app.route('/settings', methods=['GET'])
def settings():
    return render_template('settings.html')

@app.route('/docs', methods=['GET'])
def docs():
    return render_template('docs.html')

@app.route('/about', methods=['GET'])
def about():
    return render_template('about.html')

@app.route('/support', methods=['GET'])
def support():
    return render_template('support.html')

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

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok'}), 200

if __name__ == '__main__':
    app.run(debug=True)