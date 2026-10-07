"""Títulos de Wikipedia en español asociados a cada subtema del catálogo.

Cada subtema apunta a una lista de artículos ordenados por relevancia. El
enriquecedor los consulta directamente (sin usar el buscador), lo que reduce
el número de peticiones y evita que el motor de búsqueda devuelva artículos
poco relacionados. Si ningún título existe, el script cae al buscador.
"""

from __future__ import annotations

WIKI_TITLES: dict[str, list[str]] = {
    # --- Matemática · Aritmética -------------------------------------------------
    "Operaciones básicas": ["Aritmética", "Operación matemática"],
    "Números enteros y racionales": ["Número entero", "Número racional"],
    "Potencias y raíces": ["Potenciación", "Radicación"],
    "Divisibilidad y analogías": [
        "Divisibilidad",
        "Criterios de divisibilidad",
        "Número primo",
    ],
    "MCD y MCM": ["Máximo común divisor", "Mínimo común múltiplo"],
    "Proporcionalidad": ["Proporcionalidad", "Regla de tres"],
    "Porcentajes y regla de tres": ["Porcentaje", "Regla de tres"],
    "Interés simple y compuesto": ["Interés simple", "Interés compuesto"],
    "Matemática general": ["Matemáticas", "Aritmética"],
    # --- Matemática · Álgebra ----------------------------------------------------
    "Teoría de conjuntos básica": [
        "Teoría de conjuntos",
        "Conjunto",
        "Álgebra de conjuntos",
    ],
    "Ecuaciones lineales": ["Ecuación de primer grado", "Ecuación"],
    "Sistemas de ecuaciones": [
        "Sistema de ecuaciones lineales",
        "Sistema de ecuaciones",
    ],
    "Inecuaciones": ["Inecuación", "Desigualdad matemática"],
    "Operaciones con polinomios": ["Polinomio", "División polinomial"],
    "Factorización de polinomios": ["Factorización", "Polinomio"],
    "Funciones y representación": ["Función matemática", "Gráfica de una función"],
    "Función lineal y cuadrática": [
        "Función lineal",
        "Función cuadrática",
        "Parábola",
    ],
    "Logaritmos y propiedades": ["Logaritmo", "Logaritmo natural"],
    "Progresiones aritméticas y geométricas": [
        "Progresión aritmética",
        "Progresión geométrica",
    ],
    # --- Matemática · Geometría --------------------------------------------------
    "Geometría plana": ["Geometría euclidiana", "Polígono", "Ángulo"],
    "Perímetros y áreas": ["Perímetro", "Área"],
    "Volúmenes y sólidos": ["Volumen", "Poliedro", "Cuerpo de revolución"],
    "Triángulos semejantes": [
        "Semejanza (geometría)",
        "Triángulo",
        "Teorema de Tales",
    ],
    "Circunferencia y círculo": ["Circunferencia", "Círculo"],
    "Geometría analítica en el plano": [
        "Geometría analítica",
        "Coordenadas cartesianas",
        "Recta",
    ],
    # --- Matemática · Trigonometría ----------------------------------------------
    "Razones trigonométricas": ["Trigonometría", "Función trigonométrica"],
    "Funciones seno, coseno y tangente": [
        "Función trigonométrica",
        "Seno (trigonometría)",
        "Coseno",
    ],
    "Identidades trigonométricas básicas": [
        "Identidades trigonométricas",
        "Trigonometría",
    ],
    "Resolución de triángulos": [
        "Resolución de triángulos",
        "Teorema del seno",
        "Teorema del coseno",
    ],
    # --- Matemática · Estadística ------------------------------------------------
    "Estadística descriptiva": ["Estadística descriptiva", "Estadística"],
    "Media, mediana y moda": [
        "Media aritmética",
        "Mediana (estadística)",
        "Moda (estadística)",
    ],
    "Varianza y desviación estándar": ["Varianza", "Desviación típica"],
    "Gráficos y tablas": [
        "Histograma",
        "Diagrama de barras",
        "Distribución de frecuencias",
    ],
    "Probabilidad": ["Probabilidad", "Teoría de la probabilidad"],
    "Principio de conteo y combinaciones": [
        "Combinatoria",
        "Combinación",
        "Permutación",
    ],
    # --- Ciencia y Tecnología · Física -------------------------------------------
    "Movimiento y fuerzas": ["Leyes de Newton", "Fuerza", "Movimiento (física)"],
    "MRU y MRUV": [
        "Movimiento rectilíneo uniforme",
        "Movimiento rectilíneo uniformemente acelerado",
    ],
    "Trabajo y energía": ["Trabajo (física)", "Energía", "Energía cinética"],
    "Presión y principio de Arquímedes": ["Presión", "Principio de Arquímedes"],
    "Ondas y sonido": ["Onda", "Sonido"],
    "Reflexión y refracción de la luz": [
        "Reflexión (física)",
        "Refracción",
        "Óptica",
    ],
    "Calor y temperatura": ["Calor", "Temperatura", "Termodinámica"],
    "Circuitos básicos": ["Circuito eléctrico", "Ley de Ohm"],
    "Magnetismo e inducción básica": ["Magnetismo", "Inducción electromagnética"],
    # --- Ciencia y Tecnología · Química ------------------------------------------
    "Materia y cambios": ["Materia", "Cambio químico"],
    "Estados de la materia": [
        "Estado de agregación de la materia",
        "Cambio de estado",
    ],
    "Estructura atómica": ["Átomo", "Configuración electrónica"],
    "Elementos y propiedades": [
        "Tabla periódica de los elementos",
        "Elemento químico",
    ],
    "Reacciones químicas básicas": ["Reacción química", "Ecuación química"],
    "Enlace iónico y covalente": [
        "Enlace químico",
        "Enlace iónico",
        "Enlace covalente",
    ],
    "Mol y cálculos estequiométricos": ["Mol", "Estequiometría"],
    "pH, ácidos y bases": ["PH", "Ácido", "Base (química)"],
    "Introducción al carbono e hidrocarburos": [
        "Química orgánica",
        "Hidrocarburo",
        "Carbono",
    ],
    # --- Ciencia y Tecnología · Biología -----------------------------------------
    "Celular y funciones vitales": ["Célula", "Teoría celular"],
    "Niveles de organización": ["Organización biológica", "Biología"],
    "Sistemas del cuerpo humano": [
        "Anatomía humana",
        "Cuerpo humano",
        "Aparato circulatorio",
    ],
    "Taxonomía y reinos de la vida": [
        "Taxonomía",
        "Reino (biología)",
        "Clasificación biológica",
    ],
    "Herencia básica": ["Genética", "Leyes de Mendel"],
    "Reproducción sexual y asexual": ["Reproducción sexual", "Reproducción asexual"],
    "Fotosíntesis y respiración celular": ["Fotosíntesis", "Respiración celular"],
    "Ecosistemas y biodiversidad": ["Ecosistema", "Biodiversidad"],
    "Evolución y selección natural": ["Evolución biológica", "Selección natural"],
    "Microorganismos y salud": ["Microorganismo", "Bacteria", "Virus"],
    # --- Ciencia y Tecnología · Tecnología ---------------------------------------
    "Diseño de prototipos": ["Prototipo", "Diseño industrial"],
    # --- Comunicación · Lenguaje --------------------------------------------------
    "Inferencia y idea principal": ["Comprensión lectora", "Inferencia"],
    "Textos argumentativos": ["Texto argumentativo", "Argumentación"],
    "Categorías gramaticales": ["Categoría gramatical", "Gramática"],
    "Acentuación y puntuación": [
        "Acentuación del idioma español",
        "Signo de puntuación",
    ],
    "Planificación y textualización": ["Redacción", "Escritura"],
    "Revisión y coherencia": ["Coherencia textual", "Cohesión (lingüística)"],
    "Exposición y debate": ["Debate", "Discurso"],
    # --- Comunicación · Aptitud verbal --------------------------------------------
    "Oraciones incompletas": ["Oración (gramática)", "Semántica"],
    "Sinonimia y analogías verbales": ["Sinonimia", "Analogía"],
    "Antónimos y homónimos": ["Antonimia", "Homonimia"],
    "Planes de lectura y síntesis": ["Comprensión lectora", "Resumen"],
    # --- Comunicación · Literatura ------------------------------------------------
    "Metáfora, símil e hipérbole": ["Metáfora", "Símil", "Hipérbole"],
    "Narrativa y poesía": ["Narrativa", "Poesía"],
    "Teatro y ensayo": ["Teatro", "Ensayo"],
    "Autores y obras representativas": ["Literatura peruana", "Literatura"],
    # --- Ciencias Sociales · Historia ----------------------------------------------
    "Culturas prehispánicas": ["Antiguo Perú", "Imperio incaico"],
    "Virreinato y sociedad colonial": ["Virreinato del Perú"],
    "Independencia y República": ["Independencia del Perú", "Historia del Perú"],
    "Siglo XX peruano": ["Historia del Perú", "Historia contemporánea"],
    "Edad Contemporánea": ["Edad Contemporánea"],
    "Guerras mundiales y orden global": [
        "Primera Guerra Mundial",
        "Segunda Guerra Mundial",
        "Guerra Fría",
    ],
    # --- Ciencias Sociales · Geografía ---------------------------------------------
    "Relieve y clima del Perú": [
        "Geografía del Perú",
        "Cordillera de los Andes",
        "Clima del Perú",
    ],
    "Recursos naturales y riesgos": ["Recurso natural", "Desastre natural"],
    "Demografía y urbanización": ["Demografía", "Urbanización"],
    # --- Ciencias Sociales · Economía ----------------------------------------------
    "Producción y consumo": ["Producción (economía)", "Consumo"],
    "Oferta, demanda y precios": ["Oferta y demanda", "Precio"],
    "Ahorro e inversión básica": ["Ahorro", "Inversión"],
    # --- DPCC · Desarrollo personal -------------------------------------------------
    "Autoconcepto y autoestima": ["Autoconcepto", "Autoestima"],
    "Regulación emocional": ["Regulación emocional", "Inteligencia emocional"],
    "Toma de decisiones y resolución de conflictos": [
        "Toma de decisiones",
        "Resolución de conflictos",
    ],
    "Proyecto de vida": ["Proyecto de vida", "Motivación"],
    "Cuidado y responsabilidad": ["Responsabilidad", "Autocuidado"],
    # --- DPCC · Ciudadanía / Cívica --------------------------------------------------
    "Normas y acuerdos": ["Norma social", "Norma jurídica"],
    "Derechos humanos y deberes": [
        "Derechos humanos",
        "Declaración Universal de los Derechos Humanos",
    ],
    "Asuntos públicos": ["Política pública", "Esfera pública"],
    "Ciudadanía digital y desinformación": ["Desinformación", "Alfabetización digital"],
    "Organización del Estado": [
        "Estado",
        "Separación de poderes",
        "Gobierno del Perú",
    ],
    # --- Educación para el Trabajo ----------------------------------------------------
    "Propuesta de valor y cliente": ["Propuesta de valor", "Cliente (economía)"],
    "Plan de trabajo y costos": ["Plan de negocio", "Costo"],
    "Idea de negocio social": ["Emprendimiento social", "Empresa social"],
    "Ofimática y productividad": ["Ofimática", "Suite ofimática"],
    "Hojas de cálculo avanzadas básicas": ["Hoja de cálculo", "Microsoft Excel"],
    "Robótica y makers básicos": ["Robótica", "Cultura maker", "Arduino"],
    # --- Inglés como Lengua Extranjera -------------------------------------------------
    "Present and past tenses": ["Gramática del idioma inglés", "Tiempo gramatical"],
    "Future and conditionals": [
        "Gramática del idioma inglés",
        "Condicional (gramática)",
    ],
    "Comparatives and superlatives": ["Adjetivo", "Grado (gramática)"],
    "Dialogues and presentations": ["Diálogo", "Comunicación oral"],
    "Short texts and main idea": ["Comprensión lectora", "Texto"],
    "Daily life and school": ["Idioma inglés", "Vocabulario"],
    "Science and technology words": ["Tecnicismo", "Terminología"],
    "Emails and paragraphs": ["Correo electrónico", "Párrafo"],
    # --- Castellano como Segunda Lengua --------------------------------------------------
    "Saludos y rutinas": ["Saludo", "Pragmática"],
    "Textos cotidianos": ["Texto", "Comunicación"],
    "Textos breves": ["Texto", "Redacción"],
}
