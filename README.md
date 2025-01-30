# NASA Gallery
NASA Gallery(Mobile) display a list of photos from Firebase storage, the ability to view detailed information about a selected photo and easy search by name.
This is part of [cloud image manager app](https://cloudimagemanager.web.app).

## Features

- *Firebase Storage Image Procesing*: Fetch resized photos using Clound Function
- *Firebase Storege Metadata Procesing*: Fetch information about the selected photo


## Requirements

- Flutter 3.6.0 or higher
- Firebase CLI installed (npm install -g firebase-tools)
- A Firebase project with:
  - Firestore and Cloud Storage enabled
  - Earth Engine APIs enabled
- FlutterFire:
    - firebase_core: 3.8.1 or higher
    - firebase_storage: 12.3.7 or higher
    - firebase_database: 11.3.1 or higher
    - cloud_firestore: 5.6.2 or higher
    - 
### Workflow
1. Fetches a list of resized photos and presenting them on the home page
2. Once you select a photo, preview it with detailed information
3. Possibility to search for photos by name

## License
This project is licensed under the MIT License.
