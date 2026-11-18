# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" for Play Console / App Store Connect. Written for
**7.6.2+76**. The 7.6.0 notes are archived in release_notes_7.6.0.md.

7.6.1+75 was built for Play on 2026-11-16 but 7.6.2 supersedes it on both
stores (it includes everything 7.6.1 has). What 7.6.2 adds over 7.6.0:

- **Daily challenges count toward weekly quests** (34dc93f). The Daily Doer /
  Daily Adept weekly quests had no progress source, so they never moved.
- **No wall glow in Zen** (34dc93f). Zen has no walls (the snake wraps).
  Both from Marthad Osman's Play review, promised "for our next update".
- **iOS: Settings > Rate Snake Classic works.** `openStoreListing()` was
  called without the App Store ID, which iOS needs, so the row did nothing.
  The automatic review prompt on iOS now asks after 5 games / 1 day instead
  of 8 / 3 (the listing had zero ratings).
- Android only, invisible: Play's "fix your payment" in-app message
  (7ec2f00) and the edge-to-edge fix for Play's warning (e48b236).

Play's text is the same as 7.6.1's (its rate button already worked). The App
Store text adds the rate-button line. Mode names are each language's in-app
name (modeZen in the .arb files); Turkish is not an in-app language. Every
Play block fits the 500-character limit.

---

## Play Console — paste as-is

es-419 and es-ES share the `es` text.

```
<en-US>
Fixes from your feedback.

• Completing daily challenges now counts toward your weekly quests.
• Zen Mode no longer shows a wall warning glow, since Zen has no walls.
</en-US>
<ar>
إصلاحات بناءً على ملاحظاتكم.

• إكمال التحديات اليومية يُحتسب الآن ضمن مهامك الأسبوعية.
• لم يعد وضع الاسترخاء يُظهر توهج التحذير من الجدران، فلا جدران فيه.
</ar>
<es-419>
Arreglos gracias a tus comentarios.

• Completar desafíos diarios ahora cuenta para tus misiones semanales.
• El Modo Zen ya no muestra el brillo de advertencia de pared, porque no tiene paredes.
</es-419>
<es-ES>
Arreglos gracias a tus comentarios.

• Completar desafíos diarios ahora cuenta para tus misiones semanales.
• El Modo Zen ya no muestra el brillo de advertencia de pared, porque no tiene paredes.
</es-ES>
<fr-FR>
Des corrections grâce à vos retours.

• Terminer des défis quotidiens compte désormais pour vos quêtes hebdomadaires.
• Le Mode Zen n'affiche plus la lueur d'alerte des murs, puisqu'il n'a pas de murs.
</fr-FR>
<hi-IN>
आपके सुझावों से सुधार।

• डेली चैलेंज पूरे करना अब आपकी वीकली क्वेस्ट में गिना जाता है।
• ज़ेन मोड में अब दीवार की चेतावनी वाली चमक नहीं दिखती, क्योंकि इसमें दीवारें नहीं हैं।
</hi-IN>
<it-IT>
Correzioni grazie ai vostri commenti.

• Completare le sfide giornaliere ora conta per le missioni settimanali.
• La Modalità Zen non mostra più il bagliore di avviso dei muri, perché non ha muri.
</it-IT>
<pl-PL>
Poprawki dzięki Waszym opiniom.

• Ukończone wyzwania dzienne liczą się teraz do zadań tygodniowych.
• Tryb Zen nie pokazuje już ostrzegawczej poświaty ścian, bo nie ma w nim ścian.
</pl-PL>
<pt-BR>
Correções a partir do seu feedback.

• Completar desafios diários agora conta para as suas missões semanais.
• O Modo Zen não mostra mais o brilho de alerta das paredes, já que não tem paredes.
</pt-BR>
<ru-RU>
Исправления по вашим отзывам.

• Выполненные ежедневные задания теперь засчитываются в еженедельные квесты.
• В режиме «Дзен» больше нет подсветки-предупреждения о стенах: стен там нет.
</ru-RU>
<tr-TR>
Geri bildirimlerinle gelen düzeltmeler.

• Tamamladığın günlük görevler artık haftalık görevlerine sayılıyor.
• Zen Modu artık duvar uyarı parıltısı göstermiyor, çünkü Zen'de duvar yok.
</tr-TR>
```

## App Store Connect — What's New (7.6.2)

The App Store has 7.6.0 live, so this carries the 7.6.1 fixes too. The rate
line uses each language's in-app row name (settingsRateApp). Promotional
Text is unchanged; see release_notes_7.6.0.md.

**en-US / en-GB**
```
Fixes from your feedback.

• Completing daily challenges now counts toward your weekly quests.
• Zen Mode no longer shows a wall warning glow, since Zen has no walls.
• "Rate Snake Classic" in Settings now opens the App Store.
```

**ar**
```
إصلاحات بناءً على ملاحظاتكم.

• إكمال التحديات اليومية يُحتسب الآن ضمن مهامك الأسبوعية.
• لم يعد وضع الاسترخاء يُظهر توهج التحذير من الجدران، فلا جدران فيه.
• زر «قيّم Snake Classic» في الإعدادات يفتح الآن App Store.
```

**es-MX**
```
Arreglos gracias a tus comentarios.

• Completar desafíos diarios ahora cuenta para tus misiones semanales.
• El Modo Zen ya no muestra el brillo de advertencia de pared, porque no tiene paredes.
• «Valora Snake Classic» en Ajustes ahora abre el App Store.
```

**fr-FR**
```
Des corrections grâce à vos retours.

• Terminer des défis quotidiens compte désormais pour vos quêtes hebdomadaires.
• Le Mode Zen n'affiche plus la lueur d'alerte des murs, puisqu'il n'a pas de murs.
• « Noter Snake Classic » dans les Réglages ouvre désormais l'App Store.
```

**hi**
```
आपके सुझावों से सुधार।

• डेली चैलेंज पूरे करना अब आपकी वीकली क्वेस्ट में गिना जाता है।
• ज़ेन मोड में अब दीवार की चेतावनी वाली चमक नहीं दिखती, क्योंकि इसमें दीवारें नहीं हैं।
• सेटिंग्स में "Snake Classic को रेट करें" अब App Store खोलता है।
```

**it**
```
Correzioni grazie ai vostri commenti.

• Completare le sfide giornaliere ora conta per le missioni settimanali.
• La Modalità Zen non mostra più il bagliore di avviso dei muri, perché non ha muri.
• "Valuta Snake Classic" nelle Impostazioni ora apre l'App Store.
```

**pl**
```
Poprawki dzięki Waszym opiniom.

• Ukończone wyzwania dzienne liczą się teraz do zadań tygodniowych.
• Tryb Zen nie pokazuje już ostrzegawczej poświaty ścian, bo nie ma w nim ścian.
• „Oceń Snake Classic” w Ustawieniach otwiera teraz App Store.
```

**pt-BR**
```
Correções a partir do seu feedback.

• Completar desafios diários agora conta para as suas missões semanais.
• O Modo Zen não mostra mais o brilho de alerta das paredes, já que não tem paredes.
• "Avalie Snake Classic" nos Ajustes agora abre a App Store.
```

**tr**
```
Geri bildirimlerinle gelen düzeltmeler.

• Tamamladığın günlük görevler artık haftalık görevlerine sayılıyor.
• Zen Modu artık duvar uyarı parıltısı göstermiyor, çünkü Zen'de duvar yok.
• Ayarlar'daki "Snake Classic'i Değerlendir" artık App Store'u açıyor.
```
