# python - fichier de test (exécuter sur Windows: python test_requests.py)
# ...enregistrer et exécuter: python test_requests.py
import requests
cases = [
 {"amount":50.25,"hour_of_day":10,"day_of_week":2,"cat_code":3,"loc_code":1},
 {"amount":5.99,"hour_of_day":21,"day_of_week":5,"cat_code":1,"loc_code":2},
 {"amount":1200.00,"hour_of_day":2,"day_of_week":0,"cat_code":8,"loc_code":12},
 {"amount":299.99,"hour_of_day":14,"day_of_week":3,"cat_code":5,"loc_code":4},
 {"amount":15.50,"hour_of_day":12,"day_of_week":1,"cat_code":2,"loc_code":0},
 {"amount":4500.00,"hour_of_day":4,"day_of_week":6,"cat_code":10,"loc_code":9},
 {"amount":78.20,"hour_of_day":18,"day_of_week":4,"cat_code":4,"loc_code":3},
 {"amount":0.99,"hour_of_day":9,"day_of_week":2,"cat_code":0,"loc_code":1},
 {"amount":999.99,"hour_of_day":23,"day_of_week":0,"cat_code":7,"loc_code":15},
 {"amount":320.45,"hour_of_day":13,"day_of_week":5,"cat_code":6,"loc_code":2},
 {"amount":27.00,"hour_of_day":7,"day_of_week":6,"cat_code":1,"loc_code":5},
 {"amount":2150.75,"hour_of_day":1,"day_of_week":3,"cat_code":9,"loc_code":11},
 {"amount":67.89,"hour_of_day":16,"day_of_week":2,"cat_code":3,"loc_code":3},
 {"amount":13.40,"hour_of_day":11,"day_of_week":4,"cat_code":2,"loc_code":0},
 {"amount":550.00,"hour_of_day":20,"day_of_week":5,"cat_code":6,"loc_code":8},
 {"amount":5.00,"hour_of_day":3,"day_of_week":1,"cat_code":0,"loc_code":14},
 {"amount":1840.10,"hour_of_day":5,"day_of_week":0,"cat_code":11,"loc_code":13},
 {"amount":42.75,"hour_of_day":15,"day_of_week":2,"cat_code":4,"loc_code":2},
 {"amount":277.30,"hour_of_day":19,"day_of_week":6,"cat_code":5,"loc_code":6},
 {"amount":3888.88,"hour_of_day":0,"day_of_week":0,"cat_code":12,"loc_code":10},
]
url = "http://127.0.0.1:5000/predict"
for i,c in enumerate(cases,1):
    r = requests.post(url, json=c, timeout=5)
    print(i, c, "->", r.json())