import os
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.ensemble import RandomForestClassifier
import joblib
import pickle

if __name__ == "__main__":
    print("\n🚀 Training Crop & Fertilizer Recommendation Models...\n")
    
    # =========== CROP RECOMMENDATION ===========
    print("[1/2] Training Crop Recommendation Model...")
    
    # Load dataset
    data = pd.read_csv('crop_recommendation/crop_recommendation.csv')

    # Feature and target separation
    X = data[['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']]
    y = data['label']
    
    # Encode target labels
    label_encoder = LabelEncoder()
    y_encoded = label_encoder.fit_transform(y)
    
    # Split the data
    X_train, X_test, y_train, y_test = train_test_split(X, y_encoded, test_size=0.2, random_state=42)
    
    # Feature scaling
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Train model
    rf_model = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_model.fit(X_train_scaled, y_train)
    
    # Save model components
    os.makedirs('crop_recommendation', exist_ok=True)
    joblib.dump(rf_model, 'crop_recommendation/best_rf_model.joblib')
    joblib.dump(scaler, 'crop_recommendation/scaler.joblib')
    joblib.dump(label_encoder, 'crop_recommendation/label_encoder.joblib')
    
    print("✅ Crop recommendation model trained and saved!")    
    # =========== FERTILIZER RECOMMENDATION ===========
    print("\n[2/2] Training Fertilizer Recommendation Model...")
    
    # Load dataset
    fertilizer_data = pd.read_csv('fertilizer_recommendation/fertilizer.csv')
    
    # Encode categorical columns
    label_encoders = {}
    for col in ['Soil Type', 'Crop Type', 'Fertilizer Name']:
        le = LabelEncoder()
        fertilizer_data[col] = le.fit_transform(fertilizer_data[col])
        label_encoders[col] = le
    
    # Save label encoders
    os.makedirs('fertilizer_recommendation', exist_ok=True)
    with open('fertilizer_recommendation/label_encoders.pkl', 'wb') as le_file:
        pickle.dump(label_encoders, le_file)
    
    # Define features and target
    X = fertilizer_data.drop(columns=['Fertilizer Name'])
    y = fertilizer_data['Fertilizer Name']
    
    # Split data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Train the model
    fertilizer_model = RandomForestClassifier(random_state=42)
    fertilizer_model.fit(X_train, y_train)
    
    # Save the trained model
    os.makedirs('fertilizer_recommendation', exist_ok=True)
    with open('fertilizer_recommendation/fertilizer_model.pkl', 'wb') as model_file:
        pickle.dump(fertilizer_model, model_file)
        
    print("✅ Fertilizer recommendation model trained and saved!")
    print("\n✨ All models trained successfully!")

