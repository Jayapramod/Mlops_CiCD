import os
import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import subprocess
import sys


class RetrainPipeline:
    def __init__(self):
        self.base_path = os.path.dirname(os.path.abspath(__file__))

        self.crop_recommendation_dir = os.path.join(self.base_path, "crop_recommendation")
        self.fertilizer_recommendation_dir = os.path.join(self.base_path, "fertilizer_recommendation")
        self.crop_price_prediction_dir = os.path.join(self.base_path, "crop_price_prediction")

        # Email config (use environment variables in Jenkins)
        self.smtp_server = os.getenv('SMTP_SERVER', 'smtp.gmail.com')
        self.smtp_port = int(os.getenv('SMTP_PORT', 587))
        self.sender_email = os.getenv('SENDER_EMAIL')
        self.sender_password = os.getenv('SENDER_PASSWORD')
        self.recipient_email = os.getenv('RECIPIENT_EMAIL')

        self.results = {}

    # ---------------- EMAIL ---------------- #
    def send_email(self, subject, body):
        if not all([self.sender_email, self.sender_password, self.recipient_email]):
            print("⚠️ Email credentials not set. Skipping email.")
            return

        try:
            msg = MIMEMultipart()
            msg['From'] = self.sender_email
            msg['To'] = self.recipient_email
            msg['Subject'] = subject

            msg.attach(MIMEText(body, 'plain'))

            server = smtplib.SMTP(self.smtp_server, self.smtp_port)
            server.starttls()
            server.login(self.sender_email, self.sender_password)
            server.sendmail(self.sender_email, self.recipient_email, msg.as_string())
            server.quit()

            print("✅ Email sent successfully")

        except Exception as e:
            print(f"❌ Failed to send email: {e}")

    # ---------------- RUN TRAINING ---------------- #
    def run_training_script(self, script_command, model_name):
        try:
            if isinstance(script_command, str):
                cmd = ['python3', script_command]
            else:
                cmd = ['python3'] + script_command

            print(f"\n🚀 Running: {' '.join(cmd)}")

            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=self.base_path
            )

            print("STDOUT:\n", result.stdout)
            print("STDERR:\n", result.stderr)

            if result.returncode == 0:
                print(f"✅ {model_name} training SUCCESS")
                self.results[model_name] = {'status': 'success'}
                return True
            else:
                print(f"❌ {model_name} training FAILED")
                self.results[model_name] = {
                    'status': 'failed',
                    'error': result.stderr
                }
                return False

        except Exception as e:
            print(f"❌ Error running {model_name}: {e}")
            self.results[model_name] = {'status': 'failed', 'error': str(e)}
            return False

    # ---------------- ACCURACY ---------------- #
    def calculate_accuracy(self):
        print("\n📊 Calculating model accuracies...")

        # ---- Crop Recommendation ---- #
        try:
            model_path = os.path.join(self.crop_recommendation_dir, 'best_rf_model.joblib')

            if os.path.exists(model_path):
                data = pd.read_csv(os.path.join(self.crop_recommendation_dir, 'crop_recommendation.csv'))

                X = data[['N', 'P', 'K', 'temperature', 'humidity', 'ph', 'rainfall']]
                y = data['label']

                label_encoder = joblib.load(os.path.join(self.crop_recommendation_dir, 'label_encoder.joblib'))
                y_encoded = label_encoder.transform(y)

                scaler = joblib.load(os.path.join(self.crop_recommendation_dir, 'scaler.joblib'))
                X_scaled = scaler.transform(X)

                model = joblib.load(model_path)

                _, X_test, _, y_test = train_test_split(
                    X_scaled, y_encoded, test_size=0.2, random_state=42
                )

                y_pred = model.predict(X_test)
                accuracy = accuracy_score(y_test, y_pred)

                self.results['crop_recommendation']['accuracy'] = accuracy

        except Exception as e:
            print(f"⚠️ Crop accuracy error: {e}")

        # ---- Fertilizer Recommendation ---- #
        try:
            model_path = os.path.join(self.fertilizer_recommendation_dir, 'fertilizer_model.pkl')

            if os.path.exists(model_path):
                data = pd.read_csv(os.path.join(self.fertilizer_recommendation_dir, 'fertilizer.csv'))

                for col in ['Soil Type', 'Crop Type', 'Fertilizer Name']:
                    le = LabelEncoder()
                    data[col] = le.fit_transform(data[col])

                X = data.drop(columns=['Fertilizer Name'])
                y = data['Fertilizer Name']

                _, X_test, _, y_test = train_test_split(
                    X, y, test_size=0.2, random_state=42
                )

                model = joblib.load(model_path)
                y_pred = model.predict(X_test)

                accuracy = accuracy_score(y_test, y_pred)

                self.results['fertilizer_recommendation']['accuracy'] = accuracy

        except Exception as e:
            print(f"⚠️ Fertilizer accuracy error: {e}")

    # ---------------- PIPELINE ---------------- #
    def run_pipeline(self):
        print("🔥 Starting MLOps Retraining Pipeline...\n")

        # Run training scripts
        crop_fertilizer_success = self.run_training_script(
            'crop_and_fertilizer_reccomend.py',
            'crop_and_fertilizer'
        )

        price_success = self.run_training_script(
            ['crop_price_predictor.py', '--train'],
            'crop_price_prediction'
        )

        # Set model results
        if crop_fertilizer_success:
            self.results['crop_recommendation'] = {'status': 'success'}
            self.results['fertilizer_recommendation'] = {'status': 'success'}
        else:
            self.results['crop_recommendation'] = {'status': 'failed', 'error': 'Training failed'}
            self.results['fertilizer_recommendation'] = {'status': 'failed', 'error': 'Training failed'}

        if price_success:
            self.results['crop_price_prediction'] = {'status': 'success'}
        else:
            self.results['crop_price_prediction'] = {'status': 'failed', 'error': 'Training failed'}

        # Accuracy
        self.calculate_accuracy()

        # Prepare email
        all_success = crop_fertilizer_success and price_success

        subject = "MLOps Pipeline Result - "
        subject += "SUCCESS ✅" if all_success else "FAILURE ❌"

        body = "===== MLOps Pipeline Report =====\n\n"

        for model, result in self.results.items():
            status_icon = "✅" if result['status'] == 'success' else "❌"

            body += f"{status_icon} {model.upper()}\n"
            body += f"   Status: {result['status']}\n"

            if 'accuracy' in result:
                body += f"   Accuracy: {result['accuracy']:.4f}\n"

            if 'error' in result:
                body += f"   Error: {result['error']}\n"

            body += "\n"

        # Send email
        self.send_email(subject, body)

        print("\n🏁 Pipeline Finished")
        return all_success


# ---------------- MAIN ---------------- #
if __name__ == "__main__":
    pipeline = RetrainPipeline()
    success = pipeline.run_pipeline()

    if success:
        sys.exit(0)
    else:
        sys.exit(1)