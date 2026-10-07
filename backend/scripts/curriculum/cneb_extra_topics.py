"""Temas adicionales para completar el catálogo de enseñanza (sin Arte/EF/Religión)."""

from __future__ import annotations

from scripts.curriculum.cneb_catalog import CnebNode, _n

# Temas que suelen faltar en secundaria / preuniversitario
EXTRA_TEACHING_TOPICS: list[CnebNode] = [
    # Matemática
    _n("Matemática", 8, "Álgebra", "Conjuntos", "Teoría de conjuntos básica", "MAT-SET-T1", "Resuelve problemas de cantidad — conjuntos", "MAT-SET", "Álgebra — conjuntos", """
Qué es: un conjunto es una colección de elementos. Se usa lenguaje de pertenencia, unión, intersección y complemento.
"""),
    _n("Matemática", 8, "Álgebra", "Progresiones", "Progresiones aritméticas y geométricas", "MAT-PROG-T1", "Resuelve problemas de regularidad — progresiones", "MAT-PROG", "Álgebra — progresiones", """
Qué es: sucesiones con diferencia constante (aritmética) o razón constante (geométrica); fórmulas del término n-ésimo y suma.
"""),
    _n("Matemática", 8, "Álgebra", "Logaritmos", "Logaritmos y propiedades", "MAT-LOG-T1", "Resuelve problemas de regularidad — logaritmos", "MAT-LOG", "Álgebra — logaritmos", """
Qué es: el logaritmo es la operación inversa de la potencia. Propiedades de producto, cociente y potencia.
"""),
    _n("Matemática", 8, "Álgebra", "Factorización", "Factorización de polinomios", "MAT-FAC-T1", "Resuelve problemas de regularidad — factorización", "MAT-FAC", "Álgebra — factorización", """
Qué es: escribir un polinomio como producto de factores (factor común, diferencia de cuadrados, trinomio cuadrado, Aspa).
"""),
    _n("Matemática", 8, "Geometría", "Analítica", "Geometría analítica en el plano", "MAT-ANA-T1", "Resuelve problemas de forma — coordenadas", "MAT-ANA", "Geometría — analítica", """
Qué es: puntos, distancia, punto medio, ecuación de la recta y pendientes en el plano cartesiano.
"""),
    _n("Matemática", 8, "Geometría", "Circunferencia", "Circunferencia y círculo", "MAT-CIR-T1", "Resuelve problemas de forma — circunferencia", "MAT-CIR", "Geometría — circunferencia", """
Qué es: elementos (radio, cuerda, arco, tangente), ángulos inscritos/centrales y ecuaciones básicas.
"""),
    _n("Matemática", 8, "Trigonometría", "Funciones", "Funciones seno, coseno y tangente", "MAT-TRIG-F1", "Resuelve problemas de forma — funciones trigonométricas", "MAT-TRIGF", "Trigonometría — funciones", """
Qué es: extensión de las razones al círculo unitario; periodo, amplitud y gráficas básicas.
"""),
    _n("Matemática", 8, "Estadística", "Dispersión", "Varianza y desviación estándar", "MAT-VAR-T1", "Resuelve problemas de gestión de datos — dispersión", "MAT-VAR", "Estadística — dispersión", """
Qué es: medidas de dispersión que indican qué tan dispersos están los datos respecto a la media.
"""),
    _n("Matemática", 8, "Estadística", "Combinatoria", "Principio de conteo y combinaciones", "MAT-COMB-T1", "Resuelve problemas de gestión de datos — conteo", "MAT-COMB", "Estadística — combinatoria", """
Qué es: permutaciones, variaciones y combinaciones para contar casos en probabilidad.
"""),
    _n("Matemática", 8, "Aritmética", "Interés", "Interés simple y compuesto", "MAT-INT-T1", "Resuelve problemas de cantidad — interés", "MAT-INT", "Aritmética — interés", """
Qué es: cálculo de intereses en finanzas personales; diferencia entre interés simple y compuesto.
"""),
    # Física
    _n("Ciencia y Tecnología", 9, "Física", "Ã“ptica", "Reflexión y refracción de la luz", "CyT-OPT-T1", "Explica el mundo físico — óptica", "CyT-OPT", "Física — óptica", """
Qué es: leyes de reflexión y refracción; espejos, lentes y formación de imágenes (nivel introductorio).
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Termodinámica", "Calor y temperatura", "CyT-TER-T1", "Explica el mundo físico — calor", "CyT-TER", "Física — calor", """
Qué es: diferencia calor/temperatura, calor específico, cambios de estado y transferencia (conducción, convección, radiación).
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Magnetismo", "Magnetismo e inducción básica", "CyT-MAG-T1", "Explica el mundo físico — magnetismo", "CyT-MAG", "Física — magnetismo", """
Qué es: imanes, campo magnético terrestre y relación electricidad–magnetismo a nivel introductorio.
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Hidrostática", "Presión y principio de Arquímedes", "CyT-HID-T1", "Explica el mundo físico — fluidos", "CyT-HID", "Física — hidrostática", """
Qué es: presión en fluidos, principio de Pascal y empuje de Arquímedes.
"""),
    # Química
    _n("Ciencia y Tecnología", 9, "Química", "Estequiometría", "Mol y cálculos estequiométricos", "CyT-ESTQ-T1", "Explica el mundo físico — estequiometría", "CyT-ESTQ", "Química — estequiometría", """
Qué es: el mol, masa molar y relaciones cuantitativas en ecuaciones químicas balanceadas.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Ácidos y bases", "pH, ácidos y bases", "CyT-PH-T1", "Explica el mundo físico — ácidos y bases", "CyT-PH", "Química — pH", """
Qué es: ácidos y bases, escala de pH, neutralización e indicadores.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Enlace químico", "Enlace iónico y covalente", "CyT-ENL-T1", "Explica el mundo físico — enlace", "CyT-ENL", "Química — enlace", """
Qué es: cómo se unen los átomos (iónico, covalente, metálico) y cómo eso explica propiedades.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Química orgánica", "Introducción al carbono e hidrocarburos", "CyT-ORGQ-T1", "Explica el mundo físico — orgánica", "CyT-ORGQ", "Química — orgánica", """
Qué es: química del carbono, alcanos/alquenos básicos y presencia en la vida cotidiana.
"""),
    # Biología
    _n("Ciencia y Tecnología", 9, "Biología", "Fotosíntesis", "Fotosíntesis y respiración celular", "CyT-FOT-T1", "Explica el mundo natural — metabolismo", "CyT-FOT", "Biología — fotosíntesis", """
Qué es: conversión de luz en energía química y respiración celular como liberación de energía.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Reproducción", "Reproducción sexual y asexual", "CyT-REP-T1", "Explica el mundo natural — reproducción", "CyT-REP", "Biología — reproducción", """
Qué es: mecanismos de reproducción, mitosis/meiosis (idea) y diversidad genética.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Evolución", "Evolución y selección natural", "CyT-EVO-T1", "Explica el mundo natural — evolución", "CyT-EVO", "Biología — evolución", """
Qué es: cambio de poblaciones en el tiempo; selección natural, adaptación y evidencia fósil.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Clasificación", "Taxonomía y reinos de la vida", "CyT-TAX-T1", "Explica el mundo natural — clasificación", "CyT-TAX", "Biología — taxonomía", """
Qué es: clasificar seres vivos; nomenclatura binomial e idea de reinos/dominios.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Salud", "Microorganismos y salud", "CyT-SAL-T1", "Explica el mundo natural — salud", "CyT-SAL", "Biología — salud", """
Qué es: bacterias, virus, higiene, vacunas y prevención de enfermedades.
"""),
    # Comunicación
    _n("Comunicación", 5, "Lenguaje", "Ortografía", "Acentuación y puntuación", "COM-ORT-T1", "Escribe textos — normativa", "COM-ORT", "Lenguaje — ortografía", """
Qué es: reglas de tildación (agudas, graves, esdrújulas) y uso de signos de puntuación.
"""),
    _n("Comunicación", 5, "Lenguaje", "Gramática", "Categorías gramaticales", "COM-GRA-T1", "Escribe y analiza — gramática", "COM-GRA", "Lenguaje — gramática", """
Qué es: sustantivo, adjetivo, verbo, adverbio, preposición, conjunción y su función en la oración.
"""),
    _n("Comunicación", 5, "Literatura", "Figuras literarias", "Metáfora, símil e hipérbole", "COM-FIG-T1", "Lee textos literarios — figuras", "COM-FIG", "Literatura — figuras", """
Qué es: recursos retóricos para enriquecer el sentido y la estética del texto.
"""),
    _n("Comunicación", 5, "Literatura", "Géneros", "Teatro y ensayo", "COM-TEA-T1", "Lee textos literarios — teatro y ensayo", "COM-TEA", "Literatura — teatro/ensayo", """
Qué es: convenciones del drama y del ensayo; propósito, estructura y ejemplos.
"""),
    _n("Comunicación", 5, "Aptitud verbal", "Comprensión", "Planes de lectura y síntesis", "COM-SIN-T1", "Lee textos — síntesis", "COM-SIN", "Aptitud verbal — síntesis", """
Qué es: resumir sin copiar, distinguir ideas principales y secundarias, parafrasear.
"""),
    # Ciencias Sociales
    _n("Ciencias Sociales", 2, "Historia", "Historia del Perú", "Virreinato y sociedad colonial", "CS-VIR-T1", "Construye interpretaciones históricas — virreinato", "CS-VIR", "Historia — virreinato", """
Qué es: organización política, económica y social del Virreinato del Perú; mita, castas y resistencias.
"""),
    _n("Ciencias Sociales", 2, "Historia", "Historia del Perú", "Siglo XX peruano", "CS-XX-T1", "Construye interpretaciones históricas — s. XX Perú", "CS-XX", "Historia — siglo XX", """
Qué es: modernización, migraciones, reformas y conflictos del Perú contemporáneo (visión panorámica).
"""),
    _n("Ciencias Sociales", 2, "Geografía", "Población", "Demografía y urbanización", "CS-DEM-T1", "Gestiona el espacio — población", "CS-DEM", "Geografía — demografía", """
Qué es: indicadores demográficos, migración campo–ciudad y desafíos urbanos.
"""),
    _n("Ciencias Sociales", 2, "Economía", "Mercado", "Oferta, demanda y precios", "CS-MER-T1", "Gestiona recursos económicos — mercado", "CS-MER", "Economía — mercado", """
Qué es: interacción oferta–demanda, precio de equilibrio e intervención básica del Estado.
"""),
    # DPCC
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Ciudadanía", "Medios", "Ciudadanía digital y desinformación", "DPCC-DIG-T1", "Convive y participa — entornos digitales", "DPCC-DIG", "Ciudadanía — digital", """
Qué es: derechos y responsabilidades en internet; verificación de fuentes y cuidado de la privacidad.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Desarrollo personal", "Habilidades", "Toma de decisiones y resolución de conflictos", "DPCC-DEC-T1", "Construye su identidad — decisiones", "DPCC-DEC", "Desarrollo personal — decisiones", """
Qué es: proceso de decisión ética, opciones, consecuencias y mediación de conflictos.
"""),
    # Inglés
    _n("Inglés como Lengua Extranjera", 7, "Grammar", "Structures", "Comparatives and superlatives", "ING-COMP-T1", "Se comunica en inglés — comparación", "ING-COMP", "Inglés — comparatives", """
What it is: comparative and superlative forms of adjectives/adverbs for describing differences.
"""),
    _n("Inglés como Lengua Extranjera", 7, "Vocabulary", "Lexical sets", "Science and technology words", "ING-SCI-T1", "Se comunica en inglés — STEM vocab", "ING-SCI", "Inglés — STEM vocabulary", """
What it is: useful English vocabulary for science, tech and school lab contexts.
"""),
    # EPT
    _n("Educación para el Trabajo", 10, "Emprendimiento", "Marketing", "Propuesta de valor y cliente", "EPT-MKT-T1", "Gestiona proyectos — valor", "EPT-MKT", "Emprendimiento — valor", """
Qué es: definir a quién sirves, qué problema resuelves y por qué te elegirían.
"""),
    _n("Educación para el Trabajo", 10, "Tecnologías productivas", "Datos", "Hojas de cálculo avanzadas básicas", "EPT-XL-T1", "Gestiona proyectos — datos", "EPT-XL", "Trabajo — hojas de cálculo", """
Qué es: fórmulas, filtros y gráficos para tomar decisiones con datos simples.
"""),
]
