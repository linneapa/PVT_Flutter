import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

const fcm = admin.messaging();

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript

export const sendToTopic = functions.firestore
  .document('testing/{testing}')
  .onCreate(async snapshot => {
    const a = snapshot.data();

    const payload: admin.messaging.MessagingPayload = {
      notification: {
        title: 'New notification!',
        body: `${a} things are working :)`,
        click_action: 'FLUTTER_NOTIFICATION_CLICK' // required only for onResume or onLaunch callbacks
      }
    };

    return fcm.sendToTopic('testing', payload);
  });