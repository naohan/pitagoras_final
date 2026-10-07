"""Catálogo CNEB para enseñar: área → cursos → temas + teoría.

Excluye del modo aprendizaje: Educación Religiosa, Arte y Cultura, Educación Física.
Fuente base: Programa Curricular de Educación Secundaria (MINEDU / CNEB).
"""

from __future__ import annotations

from dataclasses import dataclass

from app.curriculum.constants import EXCLUDED_LEARNING_AREAS as EXCLUDED_AREA_NAMES


@dataclass(frozen=True)
class CnebNode:
    area_name: str
    area_order: int
    course_name: str
    topic_name: str
    subtopic_name: str
    cneb_code: str
    cneb_label: str
    temario_suffix: str
    temario_label: str
    theory: str


def _n(
    area: str,
    order: int,
    course: str,
    topic: str,
    subtopic: str,
    code: str,
    label: str,
    suffix: str,
    temario: str,
    theory: str,
) -> CnebNode:
    return CnebNode(
        area_name=area,
        area_order=order,
        course_name=course,
        topic_name=topic,
        subtopic_name=subtopic,
        cneb_code=code,
        cneb_label=label,
        temario_suffix=suffix,
        temario_label=temario,
        theory=theory.strip(),
    )


CNEB_FULL_CATALOG: list[CnebNode] = [
    # ——— DPCC ———
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Desarrollo personal", "Identidad", "Autoconcepto y autoestima", "DPCC-C1-T1", "Construye su identidad — se valora a sí mismo", "DPCC-ID", "Desarrollo personal — identidad", """
Qué es: el autoconcepto es la idea que tienes de ti (habilidades, valores, roles). La autoestima es la valoración afectiva de esa idea.

Ideas clave:
• Se construye con experiencias, feedback y comparación social.
• Distingue hechos (“me equivoqué en el examen”) de juicios globales (“soy un fracaso”).
• Una autoestima saludable admite errores y pide ayuda sin dejar de intentarlo.

Cómo practicarlo: escribe 3 logros recientes y 1 área de mejora con un plan concreto de 7 días.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Desarrollo personal", "Identidad", "Proyecto de vida", "DPCC-C1-T2", "Construye su identidad — proyecta su futuro", "DPCC-PV", "Desarrollo personal — proyecto de vida", """
Qué es: un proyecto de vida ordena metas personales, de estudio y de contribución social en el corto, mediano y largo plazo.

Ideas clave:
• Meta SMART: específica, medible, alcanzable, relevante y con tiempo.
• Relaciona intereses + fortalezas + oportunidades del entorno.
• Revisa el plan periódicamente; no es un destino fijo.

Cómo practicarlo: define una meta a 3 meses (estudio) y una a 1 año (formación), con 2 acciones semanales.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Desarrollo personal", "Emociones", "Regulación emocional", "DPCC-C1-T3", "Construye su identidad — gestiona emociones", "DPCC-EMO", "Desarrollo personal — emociones", """
Qué es: regular emociones es reconocerlas, nombrarlas e influir en su intensidad/duración sin reprimirlas.

Ideas clave:
• Emoción ≠ conducta: puedes sentir rabia y elegir no agredir.
• Técnicas: respiración, pausa, reencuadre cognitivo, pedir espacio.
• El estrés de exámenes baja si separamos “amenaza” de “reto entrenable”.

Cómo practicarlo: ante ansiedad, 4-7-8 (inspira 4, retén 7, exhala 8) y escribe el pensamiento automático vs. evidencia.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Desarrollo personal", "Sexualidad", "Cuidado y responsabilidad", "DPCC-C1-T4", "Construye su identidad — vive su sexualidad de manera integral", "DPCC-SEX", "Desarrollo personal — sexualidad", """
Qué es: la sexualidad integra cuerpo, afectos, identidad, vínculos y cuidados. Se vive con respeto, consentimiento e información.

Ideas clave:
• Consentimiento: libre, informado, reversible y específico.
• Autocuidado: salud, límites, prevención y acceso a información confiable.
• Rechaza mitos y presión de grupo; prioriza dignidad propia y ajena.

Cómo practicarlo: identifica 3 límites personales y cómo comunicarían “sí/no” con claridad.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Ciudadanía", "Convivencia", "Normas y acuerdos", "DPCC-C2-T1", "Convive y participa democráticamente — convive respetando", "DPCC-CONV", "Ciudadanía — convivencia", """
Qué es: la convivencia democrática se basa en reglas justas, diálogo y respeto a la diversidad.

Ideas clave:
• Normas sirven al bien común, no al privilegio.
• Conflicto ≠ violencia: se gestiona con escucha y acuerdos.
• Incluir a quienes históricamente fueron excluidos fortalece la comunidad.

Cómo practicarlo: propón un acuerdo de aula (puntualidad, turnos, respeto) y un mecanismo de revisión.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Ciudadanía", "Participación", "Asuntos públicos", "DPCC-C2-T2", "Convive y participa democráticamente — deliberación", "DPCC-PART", "Ciudadanía — participación", """
Qué es: participar es intervenir en asuntos públicos con información, argumentos y responsabilidad.

Ideas clave:
• Deliberar: escuchar, contrastar fuentes, justificar propuestas.
• Escalas: aula, barrio, municipio, país.
• Derechos van con deberes (voto informado, cuidado del espacio común).

Cómo practicarlo: elige un problema local, busca 2 fuentes y redacta una propuesta de 5 líneas.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Ciudadanía", "Derechos", "Derechos humanos y deberes", "DPCC-C2-T3", "Convive y participa democráticamente — derechos", "DPCC-DH", "Ciudadanía — derechos", """
Qué es: los derechos humanos son garantías universales (dignidad, igualdad, libertad) reconocidas en normas nacionales e internacionales.

Ideas clave:
• Universales, indivisibles e interdependientes.
• El Estado tiene deberes de respeto, protección y garantía.
• Denunciar vulneraciones es parte de la ciudadanía activa.

Cómo practicarlo: relaciona un derecho (educación, salud, no discriminación) con un caso real y qué institución interviene.
"""),
    _n("Desarrollo Personal, Ciudadanía y Cívica", 1, "Educación cívica", "Estado y democracia", "Organización del Estado", "DPCC-C2-T4", "Convive y participa — instituciones democráticas", "DPCC-EST", "Cívica — Estado", """
Qué es: el Estado peruano se organiza con separación de poderes y niveles de gobierno (nacional, regional, local).

Ideas clave:
• Poderes: Ejecutivo, Legislativo, Judicial (+ órganos autónomos).
• Democracia representativa y mecanismos de participación.
• Constitución como norma suprema.

Cómo practicarlo: diagrama quién legisla, quién ejecuta y quién juzga, con un ejemplo cotidiano (una ley municipal).
"""),

    # ——— Ciencias Sociales ———
    _n("Ciencias Sociales", 2, "Historia", "Historia del Perú", "Independencia y República", "CS-C1-T1", "Construye interpretaciones históricas — Perú", "CS-HP", "Historia del Perú", """
Qué es: proceso de ruptura del orden colonial y construcción del Estado republicano peruano (s. XIX).

Ideas clave:
• Causas internas (desigualdades, criollismo) y externas (crisis imperial, ideas liberales).
• Independencia no terminó con desigualdades; la República enfrentó caudillismo y exclusiones.
• Interpreta fuentes (proclamas, bandos, testimonios) situándolas en su contexto.

Cómo practicarlo: arma una línea de tiempo 1780–1850 con 6 hitos y una causa/consecuencia por hito.
"""),
    _n("Ciencias Sociales", 2, "Historia", "Historia del Perú", "Culturas prehispánicas", "CS-C1-T2", "Construye interpretaciones históricas — mundo andino", "CS-PRE", "Historia — culturas prehispánicas", """
Qué es: sociedades andinas y amazónicas previas a la invasión europea (Caral, Chavín, Moche, Wari, Inca, etc.).

Ideas clave:
• Complejidad política, agrícola e hidráulica.
• Reciprocidad (ayni), redistribución y control de pisos ecológicos.
• Evita el mito de “primitivo”: hay ciencia, arte y organización avanzadas.

Cómo practicarlo: compara dos culturas en economía, poder y legado material (1 cuadro).
"""),
    _n("Ciencias Sociales", 2, "Historia", "Historia universal", "Edad Contemporánea", "CS-C1-T3", "Construye interpretaciones históricas — procesos mundiales", "CS-HU", "Historia universal", """
Qué es: desde fines del s. XVIII: revoluciones, industrialización, imperialismo y nuevos órdenes políticos.

Ideas clave:
• Ilustración y revoluciones atlánticas.
• Capitalismo industrial y cambios sociales.
• Conexión con América Latina (independencias, dependencia económica).

Cómo practicarlo: explica un invento industrial y su efecto en trabajo, ciudades y comercio.
"""),
    _n("Ciencias Sociales", 2, "Historia", "Historia universal", "Guerras mundiales y orden global", "CS-C1-T4", "Construye interpretaciones históricas — siglo XX", "CS-GM", "Historia — guerras mundiales", """
Qué es: conflictos globales del s. XX que reordenaron fronteras, ideologías y derechos humanos.

Ideas clave:
• Causas: rivalidades, alianzas, nacionalismos, crisis económicas.
• Consecuencias: ONU, Guerra Fría, descolonización.
• Memoria histórica frente a genocidios y totalitarismos.

Cómo practicarlo: elige un tratado de paz y resume qué resolvió y qué dejó pendiente.
"""),
    _n("Ciencias Sociales", 2, "Geografía", "Espacio geográfico", "Relieve y clima del Perú", "CS-C2-T1", "Gestiona responsablemente el espacio y el ambiente", "CS-GEO", "Geografía del Perú", """
Qué es: el territorio peruano combina costa, sierra y selva con gran diversidad climática y de relieve.

Ideas clave:
• Relación relieve–clima–actividades humanas.
• Corriente de Humboldt, Andes y Amazonía como factores.
• Lectura de mapas: simbolos, escala, orientación.

Cómo practicarlo: describe tu región (relieve, clima, 2 recursos) y un riesgo geográfico asociado.
"""),
    _n("Ciencias Sociales", 2, "Geografía", "Ambiente", "Recursos naturales y riesgos", "CS-C2-T2", "Gestiona el espacio — ambiente y sostenibilidad", "CS-AMB", "Geografía — ambiente", """
Qué es: uso responsable de recursos y gestión de riesgos (sismos, huaycos, sequías, contaminación).

Ideas clave:
• Recursos renovables vs. no renovables.
• Desarrollo sostenible: social, económico, ambiental.
• Prevención: mapas de riesgo, preparativos familiares.

Cómo practicarlo: arma un plan familiar de 5 pasos ante sismo o inundación.
"""),
    _n("Ciencias Sociales", 2, "Economía", "Recursos económicos", "Producción y consumo", "CS-C3-T1", "Gestiona responsablemente los recursos económicos", "CS-ECO", "Economía — producción", """
Qué es: la economía estudia cómo se producen, distribuyen y consumen bienes y servicios con recursos escasos.

Ideas clave:
• Factores: tierra, trabajo, capital, emprendimiento.
• Sectores: primario, secundario, terciario.
• Consumo responsable y huella ecológica.

Cómo practicarlo: clasifica 6 productos de tu casa por sector y justifica.
"""),
    _n("Ciencias Sociales", 2, "Economía", "Finanzas personales", "Ahorro e inversión básica", "CS-C3-T2", "Gestiona recursos económicos — finanzas", "CS-FIN", "Economía — finanzas", """
Qué es: administrar ingresos, gastos, ahorro e inversión de forma planificada.

Ideas clave:
• Presupuesto: necesita / desea / prioriza.
• Interés simple vs. compuesto (idea básica).
• Evitar deudas costosas; comparar tasas y plazos.

Cómo practicarlo: haz un presupuesto semanal realista con 10% de ahorro meta.
"""),

    # ——— Comunicación ———
    _n("Comunicación", 5, "Lenguaje", "Comprensión lectora", "Inferencia y idea principal", "COM-C2-T1", "Lee diversos tipos de textos — explica el texto", "COM-LECT", "Lenguaje — comprensión lectora", """
Qué es: comprender un texto implica identificar información explícita, inferir lo implícito y sintetizar la idea principal.

Ideas clave:
• Idea principal ≠ tema: responde “qué se afirma” no solo “de qué trata”.
• Inferencia: une pistas del texto + saberes previos.
• Subraya conectores (causa, contraste, ejemplo).

Cómo practicarlo: lee un párrafo y escribe idea principal en una oración + 2 inferencias justificadas.
"""),
    _n("Comunicación", 5, "Lenguaje", "Comprensión lectora", "Textos argumentativos", "COM-C2-T2", "Lee textos — evalúa forma y contenido", "COM-ARG", "Lenguaje — textos argumentativos", """
Qué es: textos que defienden una tesis con argumentos, evidencias y contraargumentos.

Ideas clave:
• Estructura: tesis → argumentos → evidencia → conclusión.
• Tipos de argumento: autoridad, ejemplo, causa-efecto, analogía.
• Evalúa falacias y sesgos.

Cómo practicarlo: localiza la tesis de un artículo y clasifica 3 argumentos.
"""),
    _n("Comunicación", 5, "Lenguaje", "Producción escrita", "Planificación y textualización", "COM-C3-T1", "Escribe diversos tipos de textos", "COM-ESC", "Lenguaje — producción escrita", """
Qué es: escribir bien empieza planificando (propósito, destinatario, ideas) y luego textualizando con cohesión.

Ideas clave:
• Guion o mapa de ideas antes de redactar.
• Párrafo = idea central + desarrollo.
• Ajusta registro (formal/informal) al destinatario.

Cómo practicarlo: planifica un texto de 3 párrafos (intro–desarrollo–cierre) antes de escribirlo.
"""),
    _n("Comunicación", 5, "Lenguaje", "Producción escrita", "Revisión y coherencia", "COM-C3-T2", "Escribe textos — organiza y revisa", "COM-REV", "Lenguaje — revisión", """
Qué es: revisar es mejorar claridad, coherencia, cohesión, ortografía y adecuación.

Ideas clave:
• Coherencia: las ideas siguen un hilo lógico.
• Cohesión: conectores, pronombres, repeticiones controladas.
• Revisión en capas: contenido → organización → forma.

Cómo practicarlo: reescribe un párrafo eliminando 2 repeticiones y añadiendo 1 conector preciso.
"""),
    _n("Comunicación", 5, "Lenguaje", "Comunicación oral", "Exposición y debate", "COM-C1-T1", "Se comunica oralmente en su lengua materna", "COM-ORAL", "Lenguaje — oralidad", """
Qué es: comunicar oralmente con claridad, escucha activa y respeto turnos en exposiciones y debates.

Ideas clave:
• Estructura oral: gancho, mensaje, evidencia, cierre.
• Lenguaje corporal y volumen apoyan el contenido.
• En debate: ataca ideas, no personas.

Cómo practicarlo: prepara una exposición de 90 segundos con 1 ejemplo y 1 dato.
"""),
    _n("Comunicación", 5, "Literatura", "Géneros literarios", "Narrativa y poesía", "COM-LIT-T1", "Lee textos literarios — géneros", "COM-LIT", "Literatura — géneros", """
Qué es: los géneros organizan obras (narrativa, lírica, drama) con convenciones propias.

Ideas clave:
• Narrativa: narrador, personajes, conflicto, tiempo/espacio.
• Poesía: imágenes, ritmo, figuras literarias.
• Leer literatura es interpretar, no solo resumir.

Cómo practicarlo: en un cuento corto identifica narrador y conflicto; en un poema, 2 figuras.
"""),
    _n("Comunicación", 5, "Literatura", "Literatura peruana", "Autores y obras representativas", "COM-LIT-T2", "Lee textos literarios — Perú", "COM-LITP", "Literatura peruana", """
Qué es: corpus literario peruano (indígena, colonial, republicano, contemporáneo) y sus contextos.

Ideas clave:
• Relación obra–contexto social.
• Voces andinas, afroperuanas, amazónicas y urbanas.
• Temas recurrentes: identidad, desigualdad, memoria, modernidad.

Cómo practicarlo: elige un autor peruano y explica un tema de su obra con un pasaje.
"""),
    _n("Comunicación", 5, "Aptitud verbal", "Vocabulario", "Sinonimia y analogías verbales", "COM-AV-T1", "Lee textos — vocabulario y relaciones", "COM-VOC", "Aptitud verbal — analogías", """
Qué es: manejar relaciones semánticas (sinónimos, analogías) para comprender y razonar con palabras.

Ideas clave:
• Sinónimo contextual: el sentido depende de la oración.
• Analogía: A es a B como C es a D (causa, parte-todo, grado, etc.).
• Descarta trampas por parecido superficial.

Cómo practicarlo: resuelve 5 analogías nombrando el tipo de relación usado.
"""),
    _n("Comunicación", 5, "Aptitud verbal", "Vocabulario", "Antónimos y homónimos", "COM-AV-T2", "Lee textos — relaciones léxicas", "COM-ANT", "Aptitud verbal — antónimos", """
Qué es: antónimos (oposición) y homónimos/homófonos (misma forma o sonido, distinto significado).

Ideas clave:
• Antónimo gradual vs. complementario.
• Homónimos se aclaran por contexto.
• Ampliar léxico mejora comprensión lectora.

Cómo practicarlo: arma 8 pares antónimo y 4 oraciones que desambigüen homónimos.
"""),
    _n("Comunicación", 5, "Aptitud verbal", "Comprensión", "Oraciones incompletas", "COM-AV-T3", "Lee textos — coherencia local", "COM-OI", "Aptitud verbal — oraciones", """
Qué es: completar oraciones eligiendo la palabra que conserve sentido lógico y gramatical.

Ideas clave:
• Lee toda la oración antes de elegir.
• Atiende conectores y polaridad (positivo/negativo).
• Prueba mentalmente cada opción.

Cómo practicarlo: completa 6 ítems y justifica por qué las distractoras fallan.
"""),

    # ——— Castellano L2 ———
    _n("Castellano como Segunda Lengua", 6, "Comunicación oral", "Interacción", "Saludos y rutinas", "CSL-C1-T1", "Se comunica oralmente en castellano como segunda lengua", "CSL-ORAL", "Castellano L2 — oral", """
Qué es: usar castellano en intercambios cotidianos (saludos, pedidos, rutinas escolares).

Ideas clave:
• Frases modelo + variación gradual.
• Pronunciación inteligible > perfección.
• Estrategias: pedir repetición, parafrasear.

Cómo practicarlo: dramatiza un diálogo de 8 turnos (llegada al colegio / pedir ayuda).
"""),
    _n("Castellano como Segunda Lengua", 6, "Lectura", "Comprensión", "Textos cotidianos", "CSL-C2-T1", "Lee diversos tipos de textos en castellano como segunda lengua", "CSL-LEC", "Castellano L2 — lectura", """
Qué es: comprender avisos, instrucciones, mensajes y textos escolares sencillos en castellano.

Ideas clave:
• Apoyarse en imágenes, títulos y palabras conocidas.
• Subrayar verbos de instrucción (debe, no, favor de).
• Leer en voz alta para afianzar.

Cómo practicarlo: lee un aviso real y explica qué pide hacer en 3 pasos.
"""),
    _n("Castellano como Segunda Lengua", 6, "Escritura", "Producción", "Textos breves", "CSL-C3-T1", "Escribe diversos tipos de textos en castellano como segunda lengua", "CSL-ESC", "Castellano L2 — escritura", """
Qué es: producir notas, mensajes y párrafos cortos con estructura básica.

Ideas clave:
• Oración = sujeto + verbo + complemento (modelo inicial).
• Plantillas: “Hoy… / Necesito… / Porque…”
• Revisar mayúsculas y puntos.

Cómo practicarlo: escribe un mensaje de 5 oraciones pidiendo material para una tarea.
"""),

    # ——— Inglés ———
    _n("Inglés como Lengua Extranjera", 7, "Grammar", "Structures", "Present and past tenses", "ING-C1-T1", "Se comunica oralmente en inglés — estructuras", "ING-GRAM", "Inglés — grammar", """
What it is: present (simple/continuous) and past simple to talk about habits, now, and finished actions.

Key ideas:
• Present simple: habits/facts (I study every day).
• Present continuous: now (I am studying).
• Past simple: finished time (yesterday, last week) + regular/irregular verbs.

Practice: write 6 sentences (2 each tense) about your school week.
"""),
    _n("Inglés como Lengua Extranjera", 7, "Grammar", "Structures", "Future and conditionals", "ING-C1-T2", "Se comunica en inglés — tiempos futuros", "ING-FUT", "Inglés — future", """
What it is: talking about plans and possibilities with will/going to and basic conditionals.

Key ideas:
• will: decisions/promises; going to: plans/evidence.
• First conditional: If + present, will + verb.
• Keep clauses clear and parallel.

Practice: 3 plans with going to + 3 first-condition sentences about exams.
"""),
    _n("Inglés como Lengua Extranjera", 7, "Vocabulary", "Lexical sets", "Daily life and school", "ING-C1-T3", "Se comunica en inglés — vocabulario", "ING-VOC", "Inglés — vocabulary", """
What it is: word families for school, home, routines and classroom language.

Key ideas:
• Learn words in chunks (do homework, take a test).
• Collocations beat isolated lists.
• Recycle vocabulary in short speaking turns.

Practice: make a 20-word school list and 5 useful phrases.
"""),
    _n("Inglés como Lengua Extranjera", 7, "Reading", "Comprehension", "Short texts and main idea", "ING-C2-T1", "Lee diversos tipos de textos en inglés", "ING-READ", "Inglés — reading", """
What it is: understand short English texts: main idea, details and simple inferences.

Key ideas:
• Skim for gist; scan for details.
• Ignore unknown words if context is enough.
• Watch signal words (however, because, for example).

Practice: read a short paragraph and write the main idea in one English sentence.
"""),
    _n("Inglés como Lengua Extranjera", 7, "Writing", "Production", "Emails and paragraphs", "ING-C3-T1", "Escribe diversos tipos de textos en inglés", "ING-WRIT", "Inglés — writing", """
What it is: write short emails/paragraphs with clear purpose and basic cohesion.

Key ideas:
• Email frame: greeting → reason → request → closing.
• One idea per sentence at first.
• Check subject–verb agreement and punctuation.

Practice: write an 80–100 word email asking a teacher for help.
"""),
    _n("Inglés como Lengua Extranjera", 7, "Listening & Speaking", "Interaction", "Dialogues and presentations", "ING-C1-T4", "Se comunica oralmente en inglés", "ING-LS", "Inglés — speaking", """
What it is: interact in short dialogues and mini-presentations with intelligible English.

Key ideas:
• Useful starters: Could you repeat…? In my opinion…
• Fluency first, then accuracy.
• Stress content words; pause between ideas.

Practice: 60-second talk: “My study routine” with 3 points.
"""),
] + [
    # ——— Matemática ———
    _n("Matemática", 8, "Aritmética", "Números y operaciones", "Operaciones básicas", "MAT-C1-CAP1", "Resuelve problemas de cantidad — traduce cantidades", "MAT-ARIT", "Aritmética — operaciones", """
Qué es: suma, resta, multiplicación y división con enteros, fracciones y decimales, respetando jerarquía de operaciones.

Ideas clave:
• Jerarquía: ( ) → potencias/raíces → ×÷ → +−.
• Propiedades: conmutativa, asociativa, distributiva.
• Traduce el enunciado a expresión numérica antes de calcular.

Cómo practicarlo: resuelve 4 problemas contextuales escribiendo primero la expresión.
"""),
    _n("Matemática", 8, "Aritmética", "Números y operaciones", "Números enteros y racionales", "MAT-C1-T2", "Resuelve problemas de cantidad — números", "MAT-NUM", "Aritmética — números", """
Qué es: enteros y racionales (fracciones/decimales). Recta numérica, valor absoluto y reglas de signos.

Ideas clave:
• Equivalencia de fracciones; simplificar antes de operar.
• Reglas de signos en × y ÷.
• Estima el orden de magnitud.

Cómo practicarlo: ubica 6 números en la recta y calcula 4 operaciones con signos.
"""),
    _n("Matemática", 8, "Aritmética", "Números y operaciones", "Potencias y raíces", "MAT-C1-T3", "Resuelve problemas de cantidad — potencias", "MAT-POT", "Aritmética — potencias", """
Qué es: potencia aⁿ y raíz como operación inversa en casos escolares.

Ideas clave:
• aᵐ·aⁿ = aᵐ⁺ⁿ; (aᵐ)ⁿ = aᵐⁿ; a⁰ = 1 (a≠0).
• √(a·b)=√a·√b (a,b≥0).
• Diferencia (−a)ⁿ vs −aⁿ.

Cómo practicarlo: simplifica 5 expresiones con potencias y 3 con raíces.
"""),
    _n("Matemática", 8, "Aritmética", "Razones y proporciones", "Proporcionalidad", "MAT-C1-CAP3", "Resuelve problemas de cantidad — cálculo", "MAT-ARIT-PROP", "Aritmética — proporcionalidad", """
Qué es: magnitudes directa o inversamente proporcionales; constante k y regla de tres.

Ideas clave:
• Directa: más ↔ más; inversa: más ↔ menos.
• Tabla de valores para descubrir k.
• Verifica con una tercera razón.

Cómo practicarlo: clasifica 4 situaciones y resuelve 2 de cada tipo.
"""),
    _n("Matemática", 8, "Aritmética", "Razones y proporciones", "Porcentajes y regla de tres", "MAT-C1-T4", "Resuelve problemas de cantidad — porcentajes", "MAT-PORC", "Aritmética — porcentajes", """
Qué es: porcentaje = razón sobre 100 (descuentos, aumentos, impuestos).

Ideas clave:
• x% de N = (x/100)·N.
• Aumento N(1+r); descuento N(1−r).
• Regla de tres como proporción.

Cómo practicarlo: calcula precio con IGV 18% y otro con descuento 15%.
"""),
    _n("Matemática", 8, "Aritmética", "Divisibilidad", "Divisibilidad y analogías", "MAT-C1-CAP4", "Resuelve problemas de cantidad — relaciones numéricas", "MAT-ARIT-DIV", "Aritmética — divisibilidad", """
Qué es: criterios de divisibilidad y patrones numéricos (analogías).

Ideas clave:
• 3/9: suma de cifras; 2/5/10: cifra final.
• Analogías siguen una regla (×, +, series).
• Justifica la regla usada.

Cómo practicarlo: aplica criterios a 10 números y resuelve 3 analogías.
"""),
    _n("Matemática", 8, "Aritmética", "Divisibilidad", "MCD y MCM", "MAT-C1-T5", "Resuelve problemas de cantidad — MCD/MCM", "MAT-MCD", "Aritmética — MCD y MCM", """
Qué es: MCD (mayor divisor común) y MCM (menor múltiplo común) por primos o Euclides.

Ideas clave:
• MCD: exponentes mínimos; MCM: máximos.
• Repartos → MCD; ciclos → MCM.
• MCD·MCM = producto (positivos).

Cómo practicarlo: calcula 3 pares y plantea 1 problema de cada tipo.
"""),
    _n("Matemática", 8, "Aritmética", "Fundamentos", "Matemática general", "MAT-C1", "Resuelve problemas de cantidad", "MAT-GEN", "Matemática — fundamentos", """
Qué es: integrar números y operaciones para modelar problemas.

Ideas clave:
• Entender → modelar → calcular → verificar.
• Revisa unidades y sentido de la respuesta.
• Combina porcentaje + proporción con cuidado.

Cómo practicarlo: resuelve 1 problema mixto verificando el resultado.
"""),
    _n("Matemática", 8, "Álgebra", "Ecuaciones", "Ecuaciones lineales", "MAT-C1-CAP2", "Resuelve problemas de cantidad — comunica comprensión", "MAT-ALG", "Álgebra — ecuaciones", """
Qué es: ecuaciones de grado 1. Despejar manteniendo equivalencia.

Ideas clave:
• Misma operación en ambos lados.
• Verifica sustituyendo.
• Modela el enunciado antes de despejar.

Cómo practicarlo: 5 ecuaciones + 2 problemas verbales.
"""),
    _n("Matemática", 8, "Álgebra", "Ecuaciones", "Sistemas de ecuaciones", "MAT-C4-T2", "Resuelve problemas de regularidad — sistemas", "MAT-SIS", "Álgebra — sistemas", """
Qué es: sistemas 2×2 por sustitución, igualación o reducción.

Ideas clave:
• Solución = intersección de rectas.
• Elige método según coeficientes.
• Única / infinitas / ninguna.

Cómo practicarlo: 3 sistemas, uno por cada método.
"""),
    _n("Matemática", 8, "Álgebra", "Ecuaciones", "Inecuaciones", "MAT-C4-T3", "Resuelve problemas de regularidad — inecuaciones", "MAT-INE", "Álgebra — inecuaciones", """
Qué es: desigualdades lineales; al ×/÷ por negativo se invierte el sentido.

Ideas clave:
• Solución como intervalo en la recta.
• Cuidado con el signo al despejar.
• Intersección en sistemas.

Cómo practicarlo: 4 inecuaciones graficadas.
"""),
    _n("Matemática", 8, "Álgebra", "Funciones", "Funciones y representación", "MAT-C4-CAP1", "Resuelve problemas de regularidad — patrones", "MAT-FUNC", "Álgebra — funciones", """
Qué es: a cada x del dominio le corresponde un único y (tabla, fórmula, gráfica).

Ideas clave:
• Dominio/rango; criterio de la vertical.
• Patrones → expresión algebraica.
• Variable independiente/dependiente.

Cómo practicarlo: de una tabla construye f(x) y grafica 5 puntos.
"""),
    _n("Matemática", 8, "Álgebra", "Funciones", "Función lineal y cuadrática", "MAT-C4-T4", "Resuelve problemas de regularidad — funciones", "MAT-FCL", "Álgebra — lineal y cuadrática", """
Qué es: lineal y=mx+b; cuadrática y=ax²+bx+c.

Ideas clave:
• Pendiente e intercepto.
• Parábola: vértice, concavidad, raíces.
• Modelan costo, movimiento, áreas.

Cómo practicarlo: 2 pendientes + 1 vértice.
"""),
    _n("Matemática", 8, "Álgebra", "Polinomios", "Operaciones con polinomios", "MAT-C4-T5", "Resuelve problemas de regularidad — expresiones algebraicas", "MAT-POL", "Álgebra — polinomios", """
Qué es: operaciones y productos notables; factorizar como proceso inverso.

Ideas clave:
• Combinar términos semejantes.
• (a+b)², diferencia de cuadrados.
• Grado del polinomio.

Cómo practicarlo: expande 3 y factoriza 3.
"""),
    _n("Matemática", 8, "Geometría", "Figuras y medidas", "Geometría plana", "MAT-C2-CAP1", "Resuelve problemas de forma — modela objetos", "MAT-GEO", "Geometría — figuras planas", """
Qué es: ángulos, triángulos, cuadriláteros y círculos; propiedades y justificación.

Ideas clave:
• Suma ángulos triángulo = 180°.
• Clasificación por lados/ángulos.
• Dibujo auxiliar y paralelas.

Cómo practicarlo: 3 figuras con ángulos desconocidos justificados.
"""),
    _n("Matemática", 8, "Geometría", "Figuras y medidas", "Perímetros y áreas", "MAT-C2-T2", "Resuelve problemas de forma — medidas", "MAT-AREA", "Geometría — áreas", """
Qué es: perímetro (contorno) y área (superficie) con fórmulas estándar.

Ideas clave:
• Unidades coherentes.
• Figuras compuestas por descomposición.
• Círculo: 2πr y πr².

Cómo practicarlo: 4 figuras incluyendo una compuesta.
"""),
    _n("Matemática", 8, "Geometría", "Espacio", "Volúmenes y sólidos", "MAT-C2-T3", "Resuelve problemas de forma — volúmenes", "MAT-VOL", "Geometría — volúmenes", """
Qué es: volúmenes de prisma, cilindro, cono, pirámide y esfera.

Ideas clave:
• Prisma/cilindro: Abase·h.
• Cono/pirámide: (1/3)Abase·h.
• Esfera: (4/3)πr³.

Cómo practicarlo: 3 sólidos con medidas aproximadas del entorno.
"""),
    _n("Matemática", 8, "Geometría", "Semejanza", "Triángulos semejantes", "MAT-C2-T4", "Resuelve problemas de forma — semejanza", "MAT-SEM", "Geometría — semejanza", """
Qué es: misma forma, lados proporcionales, ángulos correspondientes iguales.

Ideas clave:
• Criterios AA, LAL, LLL.
• Razón k; áreas ~ k².
• Thales.

Cómo practicarlo: 2 demostraciones + 1 lado faltante.
"""),
    _n("Matemática", 8, "Trigonometría", "Triángulos", "Razones trigonométricas", "MAT-C2-CAP2", "Resuelve problemas de forma — razones trigonométricas", "MAT-TRIG", "Trigonometría — razones", """
Qué es: sen=op/hip; cos=ad/hip; tan=op/ad en triángulo rectángulo.

Ideas clave:
• Identifica opuesto/adyacente.
• sen²+cos²=1.
• Calculadora en grados.

Cómo practicarlo: 3 triángulos con sen, cos y tan.
"""),
    _n("Matemática", 8, "Trigonometría", "Triángulos", "Resolución de triángulos", "MAT-C2-T5", "Resuelve problemas de forma — triángulos", "MAT-TRIR", "Trigonometría — resolución", """
Qué es: hallar lados/ángulos con razones y Pitágoras (elevación/depresión).

Ideas clave:
• Dibuja y etiqueta.
• Elige la razón adecuada.
• Verifica con Pitágoras.

Cómo practicarlo: 2 problemas de altura/distancia.
"""),
    _n("Matemática", 8, "Trigonometría", "Identidades", "Identidades trigonométricas básicas", "MAT-C2-T6", "Resuelve problemas de forma — identidades", "MAT-IDT", "Trigonometría — identidades", """
Qué es: igualdades válidas para ángulos permitidos (p. ej. 1+tan²=sec²).

Ideas clave:
• Parte de sen²+cos²=1.
• Reescribe en sen/cos.
• Justifica cada paso.

Cómo practicarlo: demuestra 2 identidades.
"""),
    _n("Matemática", 8, "Estadística", "Datos y azar", "Estadística descriptiva", "MAT-C3-CAP1", "Resuelve problemas de gestión de datos — representa", "MAT-EST", "Estadística descriptiva", """
Qué es: organizar e interpretar datos con tablas, gráficos y medidas.

Ideas clave:
• Población/muestra; variable cualitativa/cuantitativa.
• Frecuencia absoluta y relativa.
• Evita gráficos engañosos.

Cómo practicarlo: 20 datos → tabla + gráfico.
"""),
    _n("Matemática", 8, "Estadística", "Datos y azar", "Gráficos y tablas", "MAT-C3-T2", "Resuelve problemas de gestión de datos — gráficos", "MAT-GRAF", "Estadística — gráficos", """
Qué es: barras, histogramas, circulares y líneas según el tipo de variable.

Ideas clave:
• Título, ejes, leyenda.
• Interpreta tendencias y valores atípicos.
• Elige el gráfico adecuado.

Cómo practicarlo: una tabla → 2 gráficos y compara.
"""),
    _n("Matemática", 8, "Estadística", "Datos y azar", "Probabilidad", "MAT-C3-CAP2", "Resuelve problemas de gestión de datos — probabilidad", "MAT-EST-PROB", "Estadística — probabilidad", """
Qué es: P(A) entre 0 y 1; casos favorables/posibles (Laplace).

Ideas clave:
• Complemento: P(A)+P(Aᶜ)=1.
• Independencia (idea básica).
• Experimentos equiprobables.

Cómo practicarlo: 5 cálculos con dados/cartas.
"""),
    _n("Matemática", 8, "Estadística", "Medidas", "Media, mediana y moda", "MAT-C3-T3", "Resuelve problemas de gestión de datos — medidas", "MAT-MED", "Estadística — medidas", """
Qué es: media, mediana y moda como resúmenes de un conjunto.

Ideas clave:
• Media sensible a extremos; mediana más robusta.
• Moda = valor más frecuente.
• Elige la medida según el contexto.

Cómo practicarlo: calcula las 3 y decide cuál reportar.
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Cinemática y dinámica", "Movimiento y fuerzas", "CyT-C1-CAP1", "Indaga mediante métodos científicos", "CyT-FIS", "Física — cinemática y dinámica", """
Qué es: cinemática (describir) y dinámica (fuerzas / leyes de Newton).

Ideas clave:
• v=Δx/Δt; a=Δv/Δt; F=ma.
• Diagrama de cuerpo libre.
• Inercia y acción-reacción.

Cómo practicarlo: lista fuerzas en reposo y en aceleración.
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Cinemática y dinámica", "MRU y MRUV", "CyT-FIS-T2", "Explica el mundo físico — movimiento", "CyT-MRU", "Física — MRU/MRUV", """
Qué es: MRU (v constante) y MRUV (a constante) con fórmulas y gráficas.

Ideas clave:
• x=x₀+vt; v=v₀+at; x=x₀+v₀t+½at².
• Pendiente en gráficas x-t y v-t.
• Unidades coherentes (m, s).

Cómo practicarlo: 2 MRU + 2 MRUV con gráfica cualitativa.
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Energía", "Trabajo y energía", "CyT-FIS-T3", "Explica el mundo físico — energía", "CyT-ENE", "Física — energía", """
Qué es: trabajo y energías cinética/potencial; conservación e idea de disipación.

Ideas clave:
• Ec=½mv²; Ep=mgh; W=F·d.
• Potencia = energía/tiempo.
• Fricción transforma energía útil.

Cómo practicarlo: Ec y Ep en 2 puntos de una caída.
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Ondas", "Ondas y sonido", "CyT-FIS-T4", "Explica el mundo físico — ondas", "CyT-OND", "Física — ondas", """
Qué es: ondas transportan energía; sonido = onda mecánica longitudinal.

Ideas clave:
• v=λf; periodo T=1/f.
• Transversal vs longitudinal.
• El sonido necesita medio.

Cómo practicarlo: calcula λ dados v y f.
"""),
    _n("Ciencia y Tecnología", 9, "Física", "Electricidad", "Circuitos básicos", "CyT-FIS-T5", "Explica el mundo físico — electricidad", "CyT-ELE", "Física — electricidad", """
Qué es: corriente, voltaje, resistencia y circuitos serie/paralelo (Ohm).

Ideas clave:
• V=IR.
• Serie: misma I; paralelo: misma V.
• Seguridad eléctrica básica.

Cómo practicarlo: dibuja serie y paralelo prediciendo brillo de focos.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Materia", "Materia y cambios", "CyT-C2-CAP1", "Explica el mundo físico basándose en conocimientos científicos", "CyT-QUI", "Química — materia", """
Qué es: materia, mezclas/sustancias y cambios físicos vs químicos.

Ideas clave:
• Físico: estado/forma; químico: nueva sustancia.
• Evidencias de reacción.
• Conservación de la masa (idea).

Cómo practicarlo: clasifica 8 ejemplos cotidianos.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Materia", "Estados de la materia", "CyT-QUI-T2", "Explica el mundo físico — estados", "CyT-EST", "Química — estados", """
Qué es: sólido, líquido y gas según energía y ordenamiento; cambios de estado.

Ideas clave:
• Fusión, vaporización, condensación, solidificación.
• Modelo cinético-molecular simple.
• Temperatura y agitación.

Cómo practicarlo: diagrama del agua con nombres de procesos.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Átomo", "Estructura atómica", "CyT-QUI-T3", "Explica el mundo físico — átomo", "CyT-ATO", "Química — átomo", """
Qué es: protón, neutrón y electrón; Z = número atómico.

Ideas clave:
• Isótopos e iones.
• Masa ≈ Z+N.
• Neutro: electrones = protones.

Cómo practicarlo: 3 elementos con Z, e⁻ e ion posible.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Tabla periódica", "Elementos y propiedades", "CyT-QUI-T4", "Explica el mundo físico — tabla periódica", "CyT-TP", "Química — tabla periódica", """
Qué es: organización por Z; grupos con propiedades similares.

Ideas clave:
• Metales / no metales / metaloides.
• Periodos y grupos.
• Tendencias básicas.

Cómo practicarlo: ubica 6 elementos y predice conductividad.
"""),
    _n("Ciencia y Tecnología", 9, "Química", "Reacciones", "Reacciones químicas básicas", "CyT-QUI-T5", "Explica el mundo físico — reacciones", "CyT-REA", "Química — reacciones", """
Qué es: ecuaciones químicas y balanceo; tipos básicos de reacción.

Ideas clave:
• Átomos se conservan al balancear.
• Síntesis, descomposición, combustión (básico).
• Evidencias observables.

Cómo practicarlo: balancea 4 ecuaciones e identifica el tipo.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Seres vivos", "Celular y funciones vitales", "CyT-C2-CAP2", "Explica el mundo natural — seres vivos", "CyT-BIO", "Biología — célula", """
Qué es: célula como unidad de la vida; organelos y funciones vitales.

Ideas clave:
• Procariota vs eucariota.
• Animal vs vegetal.
• Nutrición, relación, reproducción.

Cómo practicarlo: cuadro comparativo animal/vegetal (5 filas).
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Seres vivos", "Niveles de organización", "CyT-BIO-T2", "Explica el mundo natural — organización", "CyT-ORG", "Biología — organización", """
Qué es: de célula a ecosistema; emergencia de propiedades y homeostasis.

Ideas clave:
• Célula → tejido → órgano → sistema → organismo.
• Estructura–función.
• Población y comunidad.

Cómo practicarlo: sitúa un ejemplo en 6 niveles.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Sistemas", "Sistemas del cuerpo humano", "CyT-BIO-T3", "Explica el mundo natural — sistemas", "CyT-SIS", "Biología — sistemas", """
Qué es: sistemas del cuerpo y su coordinación (digestivo, respiratorio, etc.).

Ideas clave:
• Función principal por sistema.
• Interdependencia.
• Hábitos de cuidado.

Cómo practicarlo: 2 sistemas cooperando en el ejercicio.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Genética", "Herencia básica", "CyT-BIO-T4", "Explica el mundo natural — genética", "CyT-GEN", "Biología — genética", """
Qué es: genes/alelos, dominante/recesivo y cuadros de Punnett simples.

Ideas clave:
• Genotipo vs fenotipo.
• Cruce monohíbrido.
• ADN como información (idea).

Cómo practicarlo: 2 cruces monohíbridos con proporciones.
"""),
    _n("Ciencia y Tecnología", 9, "Biología", "Ecología", "Ecosistemas y biodiversidad", "CyT-BIO-T5", "Explica el mundo natural — biodiversidad", "CyT-ECO", "Biología — ecología", """
Qué es: ecosistemas, redes tróficas y biodiversidad; amenazas y conservación.

Ideas clave:
• Productores, consumidores, descomponedores.
• Factores bióticos/abióticos.
• Impacto humano.

Cómo practicarlo: red trófica local de 6 especies + 1 impacto.
"""),
    _n("Ciencia y Tecnología", 9, "Tecnología", "Soluciones tecnológicas", "Diseño de prototipos", "CyT-C3-T1", "Diseña y construye soluciones tecnológicas", "CyT-TEC", "Tecnología — diseño", """
Qué es: ciclo de diseño: necesidad → ideas → prototipo → prueba → mejora.

Ideas clave:
• Problema y restricciones claros.
• Prototipo barato y temprano.
• Criterios de evaluación.

Cómo practicarlo: problema escolar en 5 pasos de diseño.
"""),
    _n("Educación para el Trabajo", 10, "Emprendimiento", "Proyectos", "Idea de negocio social", "EPT-C1-T1", "Gestiona proyectos de emprendimiento económico y social", "EPT-EMP", "Emprendimiento", """
Qué es: crear valor económico/social resolviendo un problema real.

Ideas clave:
• Problema → propuesta → usuario.
• Validar antes de invertir.
• Impacto y sostenibilidad.

Cómo practicarlo: problema del barrio + solución en 1 párrafo.
"""),
    _n("Educación para el Trabajo", 10, "Emprendimiento", "Planificación", "Plan de trabajo y costos", "EPT-C1-T2", "Gestiona proyectos — planificación", "EPT-PLAN", "Emprendimiento — plan", """
Qué es: tareas, tiempos, responsables y costos básicos.

Ideas clave:
• Cronograma qué/quién/cuándo.
• Costos fijos vs variables (idea).
• Indicadores de avance.

Cómo practicarlo: plan de 2 semanas + presupuesto mínimo.
"""),
    _n("Educación para el Trabajo", 10, "Tecnologías productivas", "Herramientas digitales", "Ofimática y productividad", "EPT-C1-T3", "Gestiona proyectos — herramientas", "EPT-DIG", "Trabajo — herramientas digitales", """
Qué es: documentos, hojas de cálculo y presentaciones para organizar trabajo.

Ideas clave:
• Nombres de archivo y respaldos.
• Tablas y totales.
• Visuales simples para comunicar.

Cómo practicarlo: tabla de gastos + gráfico de barras.
"""),
    _n("Educación para el Trabajo", 10, "Tecnologías productivas", "Prototipado", "Robótica y makers básicos", "EPT-C1-T4", "Gestiona proyectos — prototipos", "EPT-ROB", "Trabajo — prototipado", """
Qué es: prototipos makers/robótica educativa para probar ideas.

Ideas clave:
• Sensores–control–actuadores (idea).
• Iterar barato y temprano.
• Documentar el proceso.

Cómo practicarlo: prototipo en papel para un problema del aula.
"""),
]
