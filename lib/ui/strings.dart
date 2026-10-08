class Strings {
  Strings(this.locale);
  final String locale;
  String call(String key) =>
      values[key]?[locale == 'hi'
          ? 1
          : locale == 'te'
          ? 2
          : 0] ??
      key;
  static const values = <String, List<String>>{
    'Home': ['Home', 'होम', 'హోమ్'],
    'Farm': ['Farm', 'खेत', 'పొలం'],
    'Scan': ['Scan', 'स्कैन', 'స్కాన్'],
    'Market': ['Market', 'बाज़ार', 'మార్కెట్'],
    'Account': ['Account', 'खाता', 'ఖాతా'],
    'Your farm, in focus.': [
      'Your farm, in focus.',
      'आपके खेत की पूरी जानकारी।',
      'మీ పొలం, మీ అవగాహన.',
    ],
    'A little clarity for every growing day.': [
      'A little clarity for every growing day.',
      'हर दिन खेती के लिए सही जानकारी।',
      'ప్రతి సాగు రోజుకు స్పష్టమైన సమాచారం.',
    ],
    'Choose your farm': [
      'Choose your farm',
      'अपना खेत चुनें',
      'మీ పొలాన్ని ఎంచుకోండి',
    ],
    'Save': ['Save', 'सहेजें', 'సేవ్ చేయండి'],
    'Cancel': ['Cancel', 'रद्द करें', 'రద్దు'],
    'Weather': ['Weather', 'मौसम', 'వాతావరణం'],
    'Soil record': ['Soil record', 'मिट्टी का रिकॉर्ड', 'నేల నమోదు'],
    'Crop library': ['Crop library', 'फसल संग्रह', 'పంటల గ్రంథాలయం'],
    'Recommend crops': ['Recommend crops', 'फसल सुझाव', 'పంట సూచనలు'],
    'Scan a plant': [
      'Scan a plant',
      'पौधे को स्कैन करें',
      'మొక్కను స్కాన్ చేయండి',
    ],
    'Growing starts here.': [
      'Growing starts here.',
      'खेती की शुरुआत यहाँ से।',
      'సాగు ఇక్కడ మొదలవుతుంది.',
    ],
    'Add a soil record': [
      'Add a soil record',
      'मिट्टी रिकॉर्ड जोड़ें',
      'నేల నమోదు జోడించండి',
    ],
    'Search crops': ['Search crops', 'फसल खोजें', 'పంటలను వెతకండి'],
    'Plant health': ['Plant health', 'पौधों का स्वास्थ्य', 'మొక్క ఆరోగ్యం'],
    'Look closer. Grow better.': [
      'Look closer. Grow better.',
      'ध्यान से देखें। बेहतर उगाएँ।',
      'దగ్గరగా చూడండి. బాగా పండించండి.',
    ],
    'Take a photo': ['Take a photo', 'फ़ोटो लें', 'ఫోటో తీయండి'],
    'Choose a photo': ['Choose a photo', 'फ़ोटो चुनें', 'ఫోటో ఎంచుకోండి'],
    'Retake': ['Retake', 'दोबारा लें', 'మళ్లీ తీయండి'],
    'Market watch': ['Market watch', 'बाज़ार जानकारी', 'మార్కెట్ సమాచారం'],
    'My price notes': ['My price notes', 'मेरे मूल्य नोट्स', 'నా ధర గమనికలు'],
    'Add a price note': [
      'Add a price note',
      'मूल्य नोट जोड़ें',
      'ధర గమనిక జోడించండి',
    ],
    'Your growing space.': [
      'Your growing space.',
      'आपकी खेती की जगह।',
      'మీ సాగు స్థలం.',
    ],
    'Settings': ['Settings', 'सेटिंग्स', 'సెట్టింగ్స్'],
    'Language': ['Language', 'भाषा', 'భాష'],
    'Appearance': ['Appearance', 'रूप', 'రూపం'],
    'Temperature': ['Temperature', 'तापमान', 'ఉష్ణోగ్రత'],
    'Price unit': ['Price unit', 'मूल्य इकाई', 'ధర ప్రమాణం'],
    'District': ['District', 'ज़िला', 'జిల్లా'],
    'State': ['State', 'राज्य', 'రాష్ట్రం'],
    'Guest on this device': [
      'Guest on this device',
      'इस डिवाइस पर अतिथि',
      'ఈ పరికరంలో అతిథి',
    ],
    'Saved on this device': [
      'Saved on this device',
      'इस डिवाइस पर सहेजा गया',
      'ఈ పరికరంలో సేవ్ అయింది',
    ],
    'No soil record yet': [
      'No soil record yet',
      'अभी मिट्टी रिकॉर्ड नहीं है',
      'ఇంకా నేల నమోదు లేదు',
    ],
    'Record your laboratory or kit readings. Unknown values stay blank.': [
      'Record your laboratory or kit readings. Unknown values stay blank.',
      'लैब या किट के परिणाम दर्ज करें। अज्ञात मान खाली छोड़ें।',
      'ల్యాబ్ లేదా కిట్ రీడింగులను నమోదు చేయండి. తెలియనివి ఖాళీగా ఉంచండి.',
    ],
    'Personal price note': [
      'Personal price note',
      'व्यक्तिगत मूल्य नोट',
      'వ్యక్తిగత ధర గమనిక',
    ],
    'Refresh': ['Refresh', 'ताज़ा करें', 'రిఫ్రెష్'],
    'Seven-day outlook': [
      'Seven-day outlook',
      'सात दिन का पूर्वानुमान',
      'ఏడు రోజుల అంచనా',
    ],
  };
}
