/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
// const {onRequest} = require("firebase-functions/https");
// const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({maxInstances: 10});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {WordGenerator, Language} = require("multi_language_words");

admin.initializeApp();

// Fonction pour générer les mots quotidiens automatiquement
exports.generateDailyWord = functions.pubsub
    .schedule("0 0 * * *")
    .timeZone("Europe/Paris")
    .onRun(async () => {
      const generator = new WordGenerator();
      const today = new Date().toISOString().split("T")[0];

      const english = generator.generateRandomWords(1, Language.english)[0];
      const french = generator.generateRandomWords(1, Language.french)[0];
      const spanish = generator.generateRandomWords(1, Language.spanish)[0];
      const italian = generator.generateRandomWords(1, Language.italian)[0];

      await admin.firestore()
          .collection("daily_words")
          .doc(today)
          .set({
            english: english.toUpperCase(),
            french: french.toUpperCase(),
            spanish: spanish.toUpperCase(),
            italian: italian.toUpperCase(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

      console.log(`Mots quotidiens générés pour ${today}`);
      return null;
    });

// Fonction pour récupérer le mot du jour
exports.getDailyWord = functions.https.onCall(async (data, context) => {
  const {language} = data;
  const today = new Date().toISOString().split("T")[0];

  try {
    // Vérifier si le mot du jour existe
    const doc = await admin.firestore()
        .collection("daily_words")
        .doc(today)
        .get();

    if (doc.exists) {
      const docData = doc.data();
      return {
        success: true,
        word: docData[language] || generateFallbackWord(language),
        date: today,
      };
    }

    // Si le document n'existe pas, générer un mot aléatoire
    return {
      success: true,
      word: generateFallbackWord(language),
      date: today,
      isRandom: true,
    };
  } catch (error) {
    console.error("Erreur dans getDailyWord:", error);
    return {
      success: false,
      error: error.message,
    };
  }
});

/**
 * Add two numbers.
 * @param {string} language The first number.
 * @return {string} The sum of the two numbers.
 */
function generateFallbackWord(language) {
  try {
    const generator = new WordGenerator();
    const words = generator.generateRandomWords(1, language);
    return words.length > 0 ? words[0].toUpperCase() : getDefaultWord(language);
  } catch (error) {
    console.error("Erreur génération mot:", error);
    return getDefaultWord(language);
  }
}

/**
 * Add two numbers.
 * @param {string} language The first number.
 * @return {string} The sum of the two numbers.
 */
function getDefaultWord(language) {
  const defaults = {
    english: "HELLO",
    french: "BONJOUR",
    spanish: "HOLA",
    italian: "CIAO",
  };
  return defaults[language] || "HELLO";
}

