#!/usr/bin/env python3
"""
Health Check Script for AgroX MLOps Pipeline
Verifies that all models and datasets are in place before running pipeline
"""

import os
import sys
import json
from pathlib import Path

class HealthCheck:
    def __init__(self):
        self.base_path = os.path.dirname(os.path.abspath(__file__))
        self.checks = {
            'datasets': [],
            'models': [],
            'imports': [],
            'pipeline': []
        }
        self.errors = []
        self.warnings = []

    def check_dataset_files(self):
        """Check if all required dataset files exist"""
        print("\n📊 Checking Datasets...")
        
        datasets = {
            'Crop Recommendation': 'crop_recommendation/crop_recommendation.csv',
            'Fertilizer Recommendation': 'fertilizer_recommendation/fertilizer.csv',
            'Crop Price Prediction': 'crop_price_prediction/historical_prices.csv',
        }

        for name, path in datasets.items():
            full_path = os.path.join(self.base_path, path)
            if os.path.exists(full_path):
                size_mb = os.path.getsize(full_path) / (1024 * 1024)
                print(f"  ✅ {name}: {path} ({size_mb:.2f} MB)")
                self.checks['datasets'].append({'name': name, 'status': 'OK'})
            else:
                print(f"  ❌ {name}: {path} NOT FOUND")
                self.errors.append(f"Missing dataset: {path}")
                self.checks['datasets'].append({'name': name, 'status': 'MISSING'})

    def check_model_files(self):
        """Check if trained models exist"""
        print("\n🤖 Checking Models...")
        
        models = {
            'Crop RF Model': 'crop_recommendation/best_rf_model.joblib',
            'Crop Scaler': 'crop_recommendation/scaler.joblib',
            'Crop Label Encoder': 'crop_recommendation/label_encoder.joblib',
            'Fertilizer Model': 'fertilizer_recommendation/fertilizer_model.pkl',
            'Fertilizer Encoders': 'fertilizer_recommendation/label_encoders.pkl',
            'Price LSTM Model': 'crop_price_prediction/lstm_model.h5',
            'Price Scaler': 'crop_price_prediction/price_scaler.pkl',
        }

        for name, path in models.items():
            full_path = os.path.join(self.base_path, path)
            if os.path.exists(full_path):
                size_kb = os.path.getsize(full_path) / 1024
                print(f"  ✅ {name}: {path} ({size_kb:.2f} KB)")
                self.checks['models'].append({'name': name, 'status': 'OK'})
            else:
                print(f"  ⚠️  {name}: {path} NOT FOUND")
                self.warnings.append(f"Missing model: {path} (Models will be retrained)")
                self.checks['models'].append({'name': name, 'status': 'MISSING'})

    def check_imports(self):
        """Check if all required Python packages are installed"""
        print("\n📦 Checking Python Packages...")
        
        packages = {
            'pandas': 'pd',
            'numpy': 'np',
            'sklearn': 'sklearn',
            'tensorflow': 'tf',
            'flask': 'Flask',
            'joblib': 'joblib',
        }

        for package, alias in packages.items():
            try:
                __import__(package)
                print(f"  ✅ {package}")
                self.checks['imports'].append({'name': package, 'status': 'OK'})
            except ImportError:
                print(f"  ❌ {package} NOT INSTALLED")
                self.errors.append(f"Missing package: {package}")
                self.checks['imports'].append({'name': package, 'status': 'MISSING'})

    def check_pipeline_files(self):
        """Check if pipeline files exist"""
        print("\n🔧 Checking Pipeline Files...")
        
        files = {
            'Retrain Pipeline': 'retrain_pipeline.py',
            'Crop & Fertilizer Script': 'crop_and_fertilizer_reccomend.py',
            'Price Predictor': 'crop_price_predictor.py',
            'Jenkinsfile': 'Jenkinsfile',
            'Kubernetes Deployment': 'k8s-deployment.yaml',
            'Dockerfile': 'dockerfile',
        }

        for name, filename in files.items():
            full_path = os.path.join(self.base_path, filename)
            if os.path.exists(full_path):
                print(f"  ✅ {name}: {filename}")
                self.checks['pipeline'].append({'name': name, 'status': 'OK'})
            else:
                print(f"  ❌ {name}: {filename} NOT FOUND")
                self.errors.append(f"Missing file: {filename}")
                self.checks['pipeline'].append({'name': name, 'status': 'MISSING'})

    def check_email_config(self):
        """Check if email configuration is set"""
        print("\n📧 Checking Email Configuration...")
        
        required_env_vars = [
            'SMTP_SERVER',
            'SMTP_PORT',
            'SENDER_EMAIL',
            'SENDER_PASSWORD',
            'RECIPIENT_EMAIL'
        ]

        for var in required_env_vars:
            if os.getenv(var):
                print(f"  ✅ {var}: Set")
            else:
                print(f"  ⚠️  {var}: Not Set")
                self.warnings.append(f"Environment variable {var} not set (Email will be skipped)")

    def run_all_checks(self):
        """Run all health checks"""
        print("=" * 60)
        print("🏥 AgroX MLOps Pipeline Health Check")
        print("=" * 60)

        self.check_dataset_files()
        self.check_model_files()
        self.check_imports()
        self.check_pipeline_files()
        self.check_email_config()

        # Summary
        print("\n" + "=" * 60)
        print("📋 Summary")
        print("=" * 60)

        total_checks = (
            len(self.checks['datasets']) +
            len(self.checks['models']) +
            len(self.checks['imports']) +
            len(self.checks['pipeline'])
        )

        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for error in self.errors:
                print(f"   - {error}")

        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                print(f"   - {warning}")

        if not self.errors:
            print("\n✅ All critical checks passed!")
            return True
        else:
            print(f"\n❌ {len(self.errors)} critical error(s) found!")
            return False

    def save_report(self, filename='health_check_report.json'):
        """Save health check report to file"""
        report = {
            'datasets': self.checks['datasets'],
            'models': self.checks['models'],
            'imports': self.checks['imports'],
            'pipeline': self.checks['pipeline'],
            'errors': self.errors,
            'warnings': self.warnings,
            'status': 'PASS' if not self.errors else 'FAIL'
        }

        filepath = os.path.join(self.base_path, filename)
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)

        print(f"\n📄 Report saved to: {filename}")

if __name__ == '__main__':
    checker = HealthCheck()
    success = checker.run_all_checks()
    checker.save_report()

    sys.exit(0 if success else 1)
