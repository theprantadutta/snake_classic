# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" and "Promotional Text" for Play Console / App Store
Connect. Written for **7.3.0+66**.

Scope: what a player notices against 7.2.1, which is live on the App Store
with the notes archived in release_notes_7.2.1.md. 7.2.2+65 was bumped but
never released, so its control-zone work is folded in here: the live
preview of each control layout in Settings and Pause, the board no longer
moving when the layout changes, rewarded offers that load on tap instead of
sitting greyed out, and the pause-blur and wrapping fixes.

Deliberately absent: the ad plumbing — banner auto-refresh, the consent
deadline, ad_load_stats, and the short ad after a declined rewarded intro,
which is not something to advertise.

Control-layout and feature names (SWIPE, D-PAD, TURN, STICK, Daily Bonus)
use the in-app translations from lib/l10n/app_<locale>.arb, so the notes
match the screens. The app has no Turkish UI; tr names them in Turkish.

Promotional Text is unchanged from 7.2.1 — still accurate, and App Store
Connect does not carry it over to a new version on its own.

Every What's New block fits Play's 500-character limit, so the same text
goes to both stores. App Store limits: What's New 4000, Promotional Text 170.

en-GB is not listed separately: it takes the `en` text verbatim.

---

## Play Console — paste as-is

Release → Release notes → paste this whole block. es-419 and es-ES share
the `es` text.

```
<en-US>
Better controls, rewards on tap.

• Preview before you pick: Settings and the pause menu show a live miniature of every control layout.
• Swipe, D-Pad, Turn or Stick: switching controls no longer moves the board.
• Free rewards are ready when you tap them: the Daily Bonus 2×, game over 2× coins, free tournament entry and the store's free power-up.
• Polish: a cleaner pause screen, and tips under the board no longer get cut off.
</en-US>
<ar>
تحكم أفضل ومكافآت فورية.

• شاهد قبل أن تختار: الإعدادات وقائمة الإيقاف المؤقت تعرض معاينة حية لكل نمط تحكم.
• سحب أو اتجاهات أو انعطاف أو عصا: تغيير التحكم لم يعد يحرّك اللوحة.
• المكافآت المجانية جاهزة عند النقر: المكافأة اليومية ×2، وضعف العملات عند انتهاء اللعبة، ودخول البطولة المجاني، والتعزيز المجاني في المتجر.
• لمسات أخيرة: شاشة إيقاف مؤقت أنظف، ولم تعد النصائح أسفل اللوحة تُقتطع.
</ar>
<es-419>
Mejores controles, recompensas al instante.

• Míralo antes de elegir: Ajustes y el menú de pausa muestran una vista previa en vivo de cada esquema de control.
• Deslizar, Cruceta, Girar o Stick: cambiar de control ya no mueve el tablero.
• Recompensas gratis listas al tocarlas: el Bonus Diario 2×, 2× monedas al terminar la partida, la entrada gratis al torneo y el potenciador gratis de la tienda.
• Pulido: una pantalla de pausa más limpia, y los consejos bajo el tablero ya no se cortan.
</es-419>
<es-ES>
Mejores controles, recompensas al instante.

• Míralo antes de elegir: Ajustes y el menú de pausa muestran una vista previa en vivo de cada esquema de control.
• Deslizar, Cruceta, Girar o Stick: cambiar de control ya no mueve el tablero.
• Recompensas gratis listas al tocarlas: el Bonus Diario 2×, 2× monedas al terminar la partida, la entrada gratis al torneo y el potenciador gratis de la tienda.
• Pulido: una pantalla de pausa más limpia, y los consejos bajo el tablero ya no se cortan.
</es-ES>
<fr-FR>
Meilleures commandes, récompenses sans attente.

• Voyez avant de choisir : Réglages et menu pause montrent un aperçu en direct de chaque commande.
• Balayage, D-Pad, Virage ou Joystick : changer de commande ne déplace plus le plateau.
• Récompenses gratuites prêtes dès le toucher : Bonus Quotidien 2×, pièces 2× en fin de partie, entrée de tournoi et power-up gratuit de la boutique.
• Finitions : pause plus nette, et les conseils sous le plateau ne sont plus coupés.
</fr-FR>
<hi-IN>
बेहतर कंट्रोल, टैप करते ही इनाम।

• चुनने से पहले देखें: सेटिंग्स और पॉज़ मेन्यू हर कंट्रोल लेआउट की लाइव झलक दिखाते हैं।
• स्वाइप, डी-पैड, मोड़ या स्टिक: कंट्रोल बदलने पर बोर्ड अब अपनी जगह से नहीं हिलता।
• मुफ़्त इनाम टैप करते ही तैयार: दैनिक बोनस 2×, गेम ओवर पर 2× सिक्के, मुफ़्त टूर्नामेंट एंट्री और स्टोर का मुफ़्त पावर-अप।
• निखार: साफ़ पॉज़ स्क्रीन, और बोर्ड के नीचे के टिप्स अब कटते नहीं।
</hi-IN>
<it-IT>
Comandi migliori, ricompense subito.

• Guarda prima di scegliere: Impostazioni e menu di pausa mostrano un'anteprima dal vivo di ogni schema di comandi.
• Scorri, D-Pad, Gira o Stick: cambiare comandi non sposta più il tabellone.
• Ricompense gratis pronte al tocco: il Bonus Giornaliero 2×, monete 2× a fine partita, l'ingresso gratis al torneo e il power-up gratis del negozio.
• Rifiniture: una schermata di pausa più pulita, e i consigli sotto il tabellone non vengono più tagliati.
</it-IT>
<pl-PL>
Lepsze sterowanie, nagrody od ręki.

• Zobacz, zanim wybierzesz: Ustawienia i menu pauzy pokazują podgląd na żywo każdego układu sterowania.
• Gesty, D-Pad, Skręt czy Gałka: zmiana sterowania nie przesuwa już planszy.
• Darmowe nagrody gotowe po dotknięciu: Dzienny Bonus 2×, 2× monet po grze, darmowe wejście do turnieju i darmowe wzmocnienie w sklepie.
• Szlify: czystszy ekran pauzy, a wskazówki pod planszą nie są już ucinane.
</pl-PL>
<pt-BR>
Controles melhores, recompensas na hora.

• Veja antes de escolher: os Ajustes e o menu de pausa mostram uma prévia ao vivo de cada layout de controle.
• Deslizar, D-Pad, Virar ou Joystick: trocar de controle não move mais o tabuleiro.
• Recompensas grátis prontas ao tocar: o Bônus Diário 2×, 2× moedas no fim de jogo, a entrada grátis no torneio e o power-up grátis da loja.
• Ajustes: tela de pausa mais limpa, e as dicas abaixo do tabuleiro não são mais cortadas.
</pt-BR>
<ru-RU>
Удобнее управление, награды без ожидания.

• Посмотрите, прежде чем выбрать: настройки и меню паузы показывают живое превью каждой схемы управления.
• Свайп, D-Pad, Поворот или Стик: при смене управления поле больше не сдвигается.
• Бесплатные награды готовы по нажатию: Ежедневный бонус 2×, 2× монеты после игры, бесплатный вход в турнир и бесплатное усиление в магазине.
• Доработки: аккуратнее экран паузы, а подсказки под полем больше не обрезаются.
</ru-RU>
<tr-TR>
Daha iyi kontroller, anında ödüller.

• Seçmeden önce gör: Ayarlar ve duraklatma menüsü her kontrol düzeninin canlı önizlemesini gösteriyor.
• Kaydırma, D-Pad, Dönüş ya da Joystick: kontrol değiştirmek artık tahtayı yerinden oynatmıyor.
• Ücretsiz ödüller dokununca hazır: Günlük Bonus 2×, oyun sonunda 2× jeton, ücretsiz turnuva girişi ve mağazanın ücretsiz güçlendiricisi.
• İnce ayarlar: daha temiz bir duraklatma ekranı, tahtanın altındaki ipuçları artık kesilmiyor.
</tr-TR>
```

---

## en

### What's New

Better controls, rewards on tap.

• Preview before you pick: Settings and the pause menu show a live miniature of every control layout.
• Swipe, D-Pad, Turn or Stick: switching controls no longer moves the board.
• Free rewards are ready when you tap them: the Daily Bonus 2×, game over 2× coins, free tournament entry and the store's free power-up.
• Polish: a cleaner pause screen, and tips under the board no longer get cut off.

### Promotional Text

A brand-new pixel-grid look, one more go from game over, every run charted, and smoother online duels.

---

## hi

### What's New

बेहतर कंट्रोल, टैप करते ही इनाम।

• चुनने से पहले देखें: सेटिंग्स और पॉज़ मेन्यू हर कंट्रोल लेआउट की लाइव झलक दिखाते हैं।
• स्वाइप, डी-पैड, मोड़ या स्टिक: कंट्रोल बदलने पर बोर्ड अब अपनी जगह से नहीं हिलता।
• मुफ़्त इनाम टैप करते ही तैयार: दैनिक बोनस 2×, गेम ओवर पर 2× सिक्के, मुफ़्त टूर्नामेंट एंट्री और स्टोर का मुफ़्त पावर-अप।
• निखार: साफ़ पॉज़ स्क्रीन, और बोर्ड के नीचे के टिप्स अब कटते नहीं।

### Promotional Text

बिल्कुल नया पिक्सेल-ग्रिड रूप, गेम ओवर से एक और मौक़ा, हर रन का चार्ट और ज़्यादा स्मूथ ऑनलाइन मुक़ाबले।

---

## pt

### What's New

Controles melhores, recompensas na hora.

• Veja antes de escolher: os Ajustes e o menu de pausa mostram uma prévia ao vivo de cada layout de controle.
• Deslizar, D-Pad, Virar ou Joystick: trocar de controle não move mais o tabuleiro.
• Recompensas grátis prontas ao tocar: o Bônus Diário 2×, 2× moedas no fim de jogo, a entrada grátis no torneio e o power-up grátis da loja.
• Ajustes: tela de pausa mais limpa, e as dicas abaixo do tabuleiro não são mais cortadas.

### Promotional Text

Um visual novo em grade de pixels, mais uma chance no fim de jogo, cada partida num gráfico e duelos online mais fluidos.

---

## es

### What's New

Mejores controles, recompensas al instante.

• Míralo antes de elegir: Ajustes y el menú de pausa muestran una vista previa en vivo de cada esquema de control.
• Deslizar, Cruceta, Girar o Stick: cambiar de control ya no mueve el tablero.
• Recompensas gratis listas al tocarlas: el Bonus Diario 2×, 2× monedas al terminar la partida, la entrada gratis al torneo y el potenciador gratis de la tienda.
• Pulido: una pantalla de pausa más limpia, y los consejos bajo el tablero ya no se cortan.

### Promotional Text

Un aspecto nuevo de cuadrícula de píxeles, una oportunidad más al perder, cada partida en un gráfico y duelos online más fluidos.

---

## fr

### What's New

Meilleures commandes, récompenses sans attente.

• Voyez avant de choisir : Réglages et menu pause montrent un aperçu en direct de chaque commande.
• Balayage, D-Pad, Virage ou Joystick : changer de commande ne déplace plus le plateau.
• Récompenses gratuites prêtes dès le toucher : Bonus Quotidien 2×, pièces 2× en fin de partie, entrée de tournoi et power-up gratuit de la boutique.
• Finitions : pause plus nette, et les conseils sous le plateau ne sont plus coupés.

### Promotional Text

Un tout nouveau look en grille de pixels, une chance de plus en fin de partie, chaque partie en graphique et des duels en ligne plus fluides.

---

## ru

### What's New

Удобнее управление, награды без ожидания.

• Посмотрите, прежде чем выбрать: настройки и меню паузы показывают живое превью каждой схемы управления.
• Свайп, D-Pad, Поворот или Стик: при смене управления поле больше не сдвигается.
• Бесплатные награды готовы по нажатию: Ежедневный бонус 2×, 2× монеты после игры, бесплатный вход в турнир и бесплатное усиление в магазине.
• Доработки: аккуратнее экран паузы, а подсказки под полем больше не обрезаются.

### Promotional Text

Новый облик в пиксельной сетке, ещё один шанс после проигрыша, график каждого забега и более плавные онлайн-дуэли.

---

## pl

### What's New

Lepsze sterowanie, nagrody od ręki.

• Zobacz, zanim wybierzesz: Ustawienia i menu pauzy pokazują podgląd na żywo każdego układu sterowania.
• Gesty, D-Pad, Skręt czy Gałka: zmiana sterowania nie przesuwa już planszy.
• Darmowe nagrody gotowe po dotknięciu: Dzienny Bonus 2×, 2× monet po grze, darmowe wejście do turnieju i darmowe wzmocnienie w sklepie.
• Szlify: czystszy ekran pauzy, a wskazówki pod planszą nie są już ucinane.

### Promotional Text

Nowy wygląd w siatce pikseli, jeszcze jedna szansa po końcu gry, każda gra na wykresie i płynniejsze pojedynki online.

---

## ar

### What's New

تحكم أفضل ومكافآت فورية.

• شاهد قبل أن تختار: الإعدادات وقائمة الإيقاف المؤقت تعرض معاينة حية لكل نمط تحكم.
• سحب أو اتجاهات أو انعطاف أو عصا: تغيير التحكم لم يعد يحرّك اللوحة.
• المكافآت المجانية جاهزة عند النقر: المكافأة اليومية ×2، وضعف العملات عند انتهاء اللعبة، ودخول البطولة المجاني، والتعزيز المجاني في المتجر.
• لمسات أخيرة: شاشة إيقاف مؤقت أنظف، ولم تعد النصائح أسفل اللوحة تُقتطع.

### Promotional Text

مظهر جديد بشبكة البكسلات، وفرصة أخرى عند انتهاء اللعبة، ورسم بياني لكل جولة، ومواجهات أونلاين أكثر سلاسة.

---

## it

### What's New

Comandi migliori, ricompense subito.

• Guarda prima di scegliere: Impostazioni e menu di pausa mostrano un'anteprima dal vivo di ogni schema di comandi.
• Scorri, D-Pad, Gira o Stick: cambiare comandi non sposta più il tabellone.
• Ricompense gratis pronte al tocco: il Bonus Giornaliero 2×, monete 2× a fine partita, l'ingresso gratis al torneo e il power-up gratis del negozio.
• Rifiniture: una schermata di pausa più pulita, e i consigli sotto il tabellone non vengono più tagliati.

### Promotional Text

Un nuovo aspetto a griglia di pixel, un'altra possibilità a fine partita, ogni partita in un grafico e sfide online più fluide.

---

## tr

### What's New

Daha iyi kontroller, anında ödüller.

• Seçmeden önce gör: Ayarlar ve duraklatma menüsü her kontrol düzeninin canlı önizlemesini gösteriyor.
• Kaydırma, D-Pad, Dönüş ya da Joystick: kontrol değiştirmek artık tahtayı yerinden oynatmıyor.
• Ücretsiz ödüller dokununca hazır: Günlük Bonus 2×, oyun sonunda 2× jeton, ücretsiz turnuva girişi ve mağazanın ücretsiz güçlendiricisi.
• İnce ayarlar: daha temiz bir duraklatma ekranı, tahtanın altındaki ipuçları artık kesilmiyor.

### Promotional Text

Yepyeni piksel ızgarası görünümü, oyun sonunda bir şans daha, her oyunun grafiği ve daha akıcı çevrimiçi düellolar.
