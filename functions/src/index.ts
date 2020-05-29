import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const fcm = admin.messaging();
const db = admin.firestore();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

//gets the userId from orderId
export const sendToDevice = functions.firestore
  .document('pushNotifications/{uid}')
  .onCreate(async snapshot => {


    const currentNotification = snapshot.data();

    //gets the token of the device of the user
    const querySnapshot = await db
      .collection('userData')
      .doc(currentNotification!.user)
      .collection('tokens')
      .get();

    //the name of the device(s) belonging to the user
    const tokens = querySnapshot.docs.map(snap => snap.id);

    //construct push notification
    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'Du anlände vid din destination!',
        body: 'Ge gärna feedback på trafiken :)',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    };

    //sends the push notification(s) to the users device(s)
    return fcm.sendToDevice(tokens, payload);
  });