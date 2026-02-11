# Troubleshooting Reference

## "Permission Denied" Error

If you see this error when creating a poll, check these two things in your **Firebase Console**:

### 1. Enable Anonymous Authentication (Most Likely Cause)
1. Go to **Authentication** -> **Sign-in method**.
2. Click on **Anonymous**.
3. Toggle the **Enable** switch.
4. Click **Save**.

### 2. Update Firestore Security Rules
1. Go to **Firestore Database** -> **Rules**.
2. Make sure your rules allow writes for authenticated users:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
3. Click **Publish**.

### 3. Restart App
After making these changes, fully close and restart the app:
```bash
flutter run
```
