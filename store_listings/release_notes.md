# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" and "Promotional Text" for Play Console / App Store
Connect. Written for **7.4.4+72**.

**The two stores get different text again.** Play has 7.4.3 live (notes
archived in release_notes_7.4.3.md), so the Play block covers only what
7.4.4 adds. The App Store last shipped 7.3.1, so its block also carries the
stability line from 7.4.x.

What 7.4.4 adds:

- **Zen and Speed daily challenges now count.** The server's challenges
  asked for "zen" / "speed" while a finished run reported "Zen Mode" /
  "Speed Challenge", so only Classic challenges ever progressed. A player
  reported it in a Play review (replied to on 2026-11-01, promising the fix
  in this update and a month of Pro).
- **A crash when music starts.** The music loops streamed from a temporary
  file Android can delete on low storage; about 96% of 7.4.3's Play
  crashes. Players see it as "the app closed on its own".

Mode names in the notes are each language's in-app names (modeZen,
modeSpeedChallenge in the .arb files). Turkish is not an in-app language,
so it gets a Turkish rendering.

Promotional Text is unchanged from 7.3.0 — still accurate, and App Store
Connect does not carry it over to a new version on its own.

Every What's New block fits Play's 500-character limit. App Store limits:
What's New 4000, Promotional Text 170.

en-GB is not listed separately: it takes the `en` text verbatim.

---

## App Store Connect — What's New (7.4.4)

- **en / en-GB:** Zen Mode and Speed Challenge daily challenges now count the games you play in those modes. Also fixed a crash some phones hit when the music started, plus stability fixes and smoother play.
- **ar:** تحديات وضع الاسترخاء وتحدي السرعة اليومية تحتسب الآن الألعاب التي تلعبها في هذين الوضعين. كما أصلحنا انهيارًا كان يحدث على بعض الهواتف عند بدء الموسيقى، مع إصلاحات لتحسين الثبات ولعب أكثر سلاسة.
- **es-MX:** Los desafíos diarios de Modo Zen y Desafío de Velocidad ahora cuentan las partidas que juegas en esos modos. También corregimos un cierre inesperado al empezar la música en algunos teléfonos, además de mejoras de estabilidad y un juego más fluido.
- **fr:** Les défis quotidiens Mode Zen et Défi de Vitesse comptent désormais les parties jouées dans ces modes. Nous avons aussi corrigé un plantage au lancement de la musique sur certains téléphones, avec des corrections de stabilité et un jeu plus fluide.
- **hi:** ज़ेन मोड और स्पीड चैलेंज के डेली चैलेंज अब उन मोड में खेले गए गेम गिनते हैं। कुछ फ़ोन पर म्यूज़िक शुरू होते समय होने वाला क्रैश भी ठीक किया गया है, साथ ही स्थिरता में सुधार और ज़्यादा स्मूथ गेमप्ले।
- **it:** Le sfide giornaliere di Modalità Zen e Sfida di Velocità ora contano le partite giocate in quelle modalità. Abbiamo anche corretto un arresto anomalo all'avvio della musica su alcuni telefoni, oltre a correzioni di stabilità e un gioco più fluido.
- **pl:** Codzienne wyzwania Tryb Zen i Wyzwanie prędkości liczą teraz gry rozegrane w tych trybach. Naprawiliśmy też awarię przy włączaniu muzyki na niektórych telefonach, a do tego poprawki stabilności i płynniejsza rozgrywka.
- **pt-BR:** Os desafios diários de Modo Zen e Desafio de Velocidade agora contam as partidas jogadas nesses modos. Também corrigimos um fechamento inesperado ao iniciar a música em alguns celulares, além de correções de estabilidade e um jogo mais fluido.
- **tr:** Zen Modu ve Hız Mücadelesi günlük görevleri artık bu modlarda oynadığın oyunları sayıyor. Bazı telefonlarda müzik başlarken yaşanan çökmeyi de düzelttik; ayrıca kararlılık düzeltmeleri ve daha akıcı oyun.

---

## Play Console — paste as-is

Release → Release notes → paste this whole block. es-419 and es-ES share
the `es` text.

```
<en-US>
Fixes from your feedback.

• Zen Mode and Speed Challenge daily challenges now count the games you play in those modes.
• Fixed a crash some phones hit when the music started.
</en-US>
<ar>
إصلاحات بناءً على ملاحظاتكم.

• تحديات وضع الاسترخاء وتحدي السرعة اليومية تحتسب الآن الألعاب التي تلعبها في هذين الوضعين.
• إصلاح انهيار كان يحدث على بعض الهواتف عند بدء الموسيقى.
</ar>
<es-419>
Arreglos gracias a tus comentarios.

• Los desafíos diarios de Modo Zen y Desafío de Velocidad ahora cuentan las partidas que juegas en esos modos.
• Corregimos un cierre inesperado al empezar la música en algunos teléfonos.
</es-419>
<es-ES>
Arreglos gracias a tus comentarios.

• Los desafíos diarios de Modo Zen y Desafío de Velocidad ahora cuentan las partidas que juegas en esos modos.
• Corregimos un cierre inesperado al empezar la música en algunos teléfonos.
</es-ES>
<fr-FR>
Des corrections grâce à vos retours.

• Les défis quotidiens Mode Zen et Défi de Vitesse comptent désormais les parties jouées dans ces modes.
• Correction d'un plantage au lancement de la musique sur certains téléphones.
</fr-FR>
<hi-IN>
आपके सुझावों से सुधार।

• ज़ेन मोड और स्पीड चैलेंज के डेली चैलेंज अब उन मोड में खेले गए गेम गिनते हैं।
• कुछ फ़ोन पर म्यूज़िक शुरू होते समय होने वाला क्रैश ठीक किया गया।
</hi-IN>
<it-IT>
Correzioni grazie ai vostri commenti.

• Le sfide giornaliere di Modalità Zen e Sfida di Velocità ora contano le partite giocate in quelle modalità.
• Corretto un arresto anomalo all'avvio della musica su alcuni telefoni.
</it-IT>
<pl-PL>
Poprawki dzięki Waszym opiniom.

• Codzienne wyzwania Tryb Zen i Wyzwanie prędkości liczą teraz gry rozegrane w tych trybach.
• Naprawiono awarię przy włączaniu muzyki na niektórych telefonach.
</pl-PL>
<pt-BR>
Correções a partir do seu feedback.

• Os desafios diários de Modo Zen e Desafio de Velocidade agora contam as partidas jogadas nesses modos.
• Corrigimos um fechamento inesperado ao iniciar a música em alguns celulares.
</pt-BR>
<ru-RU>
Исправления по вашим отзывам.

• Ежедневные задания режимов «Дзен» и «Скоростной вызов» теперь засчитывают игры в этих режимах.
• Исправлен вылет при запуске музыки на некоторых телефонах.
</ru-RU>
<tr-TR>
Geri bildirimlerinle gelen düzeltmeler.

• Zen Modu ve Hız Mücadelesi günlük görevleri artık bu modlarda oynadığın oyunları sayıyor.
• Bazı telefonlarda müzik başlarken yaşanan çökme düzeltildi.
</tr-TR>
```

---

## Promotional Text (App Store, unchanged from 7.3.0)

- **en / en-GB:** A brand-new pixel-grid look, one more go from game over, every run charted, and smoother online duels.
- **ar:** مظهر جديد بشبكة البكسلات، وفرصة أخرى عند انتهاء اللعبة، ورسم بياني لكل جولة، ومواجهات أونلاين أكثر سلاسة.
- **es:** Un aspecto nuevo de cuadrícula de píxeles, una oportunidad más al perder, cada partida en un gráfico y duelos online más fluidos.
- **fr:** Un tout nouveau look en grille de pixels, une chance de plus en fin de partie, chaque partie en graphique et des duels en ligne plus fluides.
- **hi:** बिल्कुल नया पिक्सेल-ग्रिड रूप, गेम ओवर से एक और मौक़ा, हर रन का चार्ट और ज़्यादा स्मूथ ऑनलाइन मुक़ाबले।
- **it:** Un nuovo aspetto a griglia di pixel, un'altra possibilità a fine partita, ogni partita in un grafico e sfide online più fluide.
- **pl:** Nowy wygląd w siatce pikseli, jeszcze jedna szansa po końcu gry, każda gra na wykresie i płynniejsze pojedynki online.
- **pt:** Um visual novo em grade de pixels, mais uma chance no fim de jogo, cada partida num gráfico e duelos online mais fluidos.
- **ru:** Новый облик в пиксельной сетке, ещё один шанс после проигрыша, график каждого забега и более плавные онлайн-дуэли.
- **tr:** Yepyeni piksel ızgarası görünümü, oyun sonunda bir şans daha, her oyunun grafiği ve daha akıcı çevrimiçi düellolar.
