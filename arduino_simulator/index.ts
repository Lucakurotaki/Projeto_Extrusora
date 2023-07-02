import { initializeApp } from "firebase/app";
import { getDatabase, onValue, ref } from "firebase/database";

const firebaseConfig = {
  apiKey: "AIzaSyBUQS_TAce_ntvlzB_IYm8_eZDx6t-p4A8",
  authDomain: "extruder-app.firebaseapp.com",
  databaseURL: "https://extruder-app-default-rtdb.firebaseio.com",
  projectId: "extruder-app",
  storageBucket: "extruder-app.appspot.com",
  messagingSenderId: "566880632642",
  appId: "1:566880632642:web:dbd46200d01d2e79c752db",
  measurementId: "G-ZZGSYDQ9M0"
};

const app = initializeApp(firebaseConfig);
const database = getDatabase(app);

export {database, ref, onValue};