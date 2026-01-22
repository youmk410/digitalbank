import pandas as pd
import pickle
from sklearn.ensemble import RandomForestClassifier

# 1. Je charge les données pour entraîner l'IA
df = pd.read_csv('sample_transactions.csv')

# 2. Préparation rapide (comme avant)
df['cat_code'] = df['merchant_category'].astype('category').cat.codes
df['loc_code'] = df['location'].astype('category').cat.codes

X = df[['amount', 'hour_of_day', 'day_of_week', 'cat_code', 'loc_code']]
y = df['is_fraud']

# 3. Création et entraînement du modèle
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)
print("✅ Modèle entraîné !")

# 4. SAUVEGARDE (C'est ici que 'model' est enfin défini)
with open('fraud_model.pkl', 'wb') as f:
    pickle.dump(model, f)

print("✅ Fichier 'fraud_model.pkl' créé avec succès !")