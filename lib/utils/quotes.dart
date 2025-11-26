// Frases motivacionales estilo Goggins

class MotivationalQuotes {
  // Modo Goggins Brutal (Directo, sin excusas)
  static const List<String> gogginsBrutal = [
    "El espejo no miente. ¿Quién eres realmente?",
    "Deja de ser una p*ta víctima. ACTÚA.",
    "Tu mente es tu enemigo #1. Cállala y MUÉVETE.",
    "40% es cuando crees que terminaste. Apenas empiezas.",
    "¿Quién va a llevar los botes? TÚ vas a llevarlos.",
    "El dolor es temporal, el orgullo es para siempre.",
    "No negocies con tu mente débil. DOMÍNALA.",
    "La vida no te debe una mierda. SAL Y TÓMALA.",
    "Cuando quieres parar, apenas vas al 40%. CONTINÚA.",
    "El sufrimiento es la prueba de que estás vivo. ACEPTA.",
    "Todos los días es el día del juicio. ¿Listo?",
    "La incomodidad es donde creces. VIVE AHÍ.",
    "Deja de buscar excusas y encuentra RESULTADOS.",
    "Tu único enemigo está en el espejo. DESTRÚYELO.",
    "La mediocridad es una enfermedad. TÚ DECIDES.",
    "No hay atajos. Solo sangre, sudor y lágrimas.",
    "Haz lo que odias como amas a quien eres.",
    "El calendario avanza. Tú decides si avanzas con él.",
    "Tu palabra vale mierda si no la cumples.",
    "La comodidad es el enemigo del crecimiento.",
    "Cada vez que te rindes, esa versión débil gana.",
    "No es sobre sentirte bien. Es sobre SER mejor.",
    "Tu mente dirá mil excusas. Ignóralas TODAS.",
    "El espejo te ve cuando nadie más te ve.",
    "Levántate y haz lo que prometiste, cobarde.",
    "La disciplina come motivación en el desayuno.",
    "Cuando duela, ahí es donde empieza la magia.",
    "No esperes sentirte listo. HAZLO igual.",
    "Tu legado se construye en los días malos.",
    "La versión dura de ti está esperando. DESPIÉRTALA.",
  ];

  // Modo Suave pero Motivador
  static const List<String> motivationalSoft = [
    "Avanza aunque sea un paso.",
    "Ten compasión, pero no te rindas.",
    "El tú de mañana te agradecerá.",
    "Cada pequeño esfuerzo cuenta.",
    "Mereces cumplir tus metas.",
    "La constancia vence al talento.",
    "Hoy puedes ser mejor que ayer.",
    "Tu esfuerzo no pasa desapercibido.",
    "Recuerda por qué empezaste.",
    "Eres más fuerte de lo que crees.",
    "El progreso no tiene que ser perfecto.",
    "Dale una oportunidad a tu mejor versión.",
    "Respeta tus compromisos contigo mismo.",
    "La disciplina es amor propio.",
    "Un día a la vez. Puedes hacerlo.",
  ];

  // Modo Equilibrado
  static const List<String> balanced = [
    "Tus metas te esperan. Empieza ahora.",
    "Sé disciplinado, pero amable contigo.",
    "¿Qué harías si no tuvieras miedo?",
    "El éxito es la suma de pequeños esfuerzos.",
    "Hoy es tu oportunidad de brillar.",
    "La consistencia es el secreto.",
    "No negocies lo que mereces.",
    "Haz lo difícil ahora, disfruta después.",
    "Tú defines tu estándar.",
    "La acción cura el miedo.",
    "Elige el progreso sobre la perfección.",
    "Tu única competencia eres tú ayer.",
    "Dale sentido a este día.",
    "El respeto propio se gana con acciones.",
    "Honra tus palabras con hechos.",
  ];

  // Frases para check-in nocturno
  static const List<String> checkInPrompts = [
    "¿Cumpliste lo que prometiste hoy?",
    "¿Fuiste la persona que querías ser hoy?",
    "¿Hiciste lo difícil o lo fácil?",
    "¿Qué tan orgulloso estás de hoy?",
    "¿Te fallaste o te cumpliste?",
    "¿Hoy avanzaste o retrocediste?",
    "¿Qué dirías al espejo ahora?",
    "¿Qué versión de ti apareció hoy?",
  ];

  // Obtener frase aleatoria según modo
  static String getRandomQuote(String mode) {
    final random = DateTime.now().millisecondsSinceEpoch;
    
    switch (mode) {
      case 'brutal':
        return gogginsBrutal[random % gogginsBrutal.length];
      case 'soft':
        return motivationalSoft[random % motivationalSoft.length];
      case 'balanced':
      default:
        return balanced[random % balanced.length];
    }
  }

  static String getCheckInPrompt() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return checkInPrompts[random % checkInPrompts.length];
  }
}
