# Release notes — pending submission

<!-- Not named for a version on purpose. This file is the "What's new" text
     for whatever ships next, rewritten in place each release; pinning a
     number to it only guarantees the name goes stale at the next bump.
     A release that actually shipped is archived as release_notes_<v>.md. -->

Paste-ready "What's new" and "Promotional Text" for Play Console / App Store
Connect. Written for **7.3.1+67**.

Scope: what a player notices against 7.3.0, which is live on the App Store
with the notes archived in release_notes_7.3.0.md. Pro renewals are checked
with the store every day (the server's daily reconcile against the App Store
and Play APIs), and restore / Go Pro now say when a purchase belongs to a
different Snake Classic account instead of appearing to do nothing.

Deliberately absent: the webhook retry and appAccountToken plumbing behind
the renewal fix, and the duplicate cancel event, which no player sees.

Promotional Text is unchanged from 7.3.0 — still accurate, and App Store
Connect does not carry it over to a new version on its own.

Every What's New block fits Play's 500-character limit, so the same text
goes to both stores. App Store limits: What's New 4000, Promotional Text 170.

en-GB is not listed separately: it takes the `en` text verbatim.

**App Store Connect: entered and saved for all 10 locales on 2026-10-22**
(en-US, en-GB, ar, fr, hi, it, pl, pt-BR, es-MX, tr), checked after a page
reload.

---

## Play Console — paste as-is

Release → Release notes → paste this whole block. es-419 and es-ES share
the `es` text.

```
<en-US>
Purchases you can count on.

• Pro renewals are now double-checked with the store every day, so your subscription stays on.
• More than one account? Purchases stay with the account you bought them on. Restore now tells you when something was bought on another account, so you know which one to sign in with.
• Small fixes in the store.
</en-US>
<ar>
مشتريات يمكنك الاعتماد عليها.

• يتم الآن التحقق من تجديدات Pro مع المتجر يوميًا، ليبقى اشتراكك فعّالًا.
• هل لديك أكثر من حساب؟ تبقى المشتريات في الحساب الذي اشتريتها به. عند الاستعادة، يخبرك التطبيق الآن إذا تم شراء شيء بحساب آخر، لتعرف بأي حساب تسجّل الدخول.
• إصلاحات صغيرة في المتجر.
</ar>
<es-419>
Compras en las que puedes confiar.

• Las renovaciones de Pro ahora se verifican con la tienda cada día, para que tu suscripción siga activa.
• ¿Tienes más de una cuenta? Las compras se quedan en la cuenta con la que las hiciste. Al restaurar, la app te avisa si algo se compró con otra cuenta, para que sepas con cuál iniciar sesión.
• Pequeños arreglos en la tienda.
</es-419>
<es-ES>
Compras en las que puedes confiar.

• Las renovaciones de Pro ahora se verifican con la tienda cada día, para que tu suscripción siga activa.
• ¿Tienes más de una cuenta? Las compras se quedan en la cuenta con la que las hiciste. Al restaurar, la app te avisa si algo se compró con otra cuenta, para que sepas con cuál iniciar sesión.
• Pequeños arreglos en la tienda.
</es-ES>
<fr-FR>
Des achats sur lesquels compter.

• Les renouvellements Pro sont désormais vérifiés chaque jour auprès de la boutique, pour que votre abonnement reste actif.
• Plusieurs comptes ? Les achats restent liés au compte avec lequel vous les avez faits. La restauration vous indique désormais quand un achat appartient à un autre compte, pour savoir avec lequel vous connecter.
• Petites corrections dans la boutique.
</fr-FR>
<hi-IN>
ऐसी ख़रीदारी जिस पर भरोसा कर सकें।

• Pro रिन्यूअल अब हर दिन स्टोर से जाँचे जाते हैं, ताकि आपका सब्सक्रिप्शन चालू रहे।
• एक से ज़्यादा अकाउंट हैं? ख़रीदारी उसी अकाउंट में रहती है जिससे आपने ख़रीदा था। रिस्टोर करते समय ऐप अब बताता है कि कोई चीज़ दूसरे अकाउंट से ख़रीदी गई थी, ताकि आप जानें किस अकाउंट से साइन इन करना है।
• स्टोर में छोटे सुधार।
</hi-IN>
<it-IT>
Acquisti su cui contare.

• I rinnovi Pro ora vengono verificati ogni giorno con lo store, così il tuo abbonamento resta attivo.
• Hai più di un account? Gli acquisti restano sull'account con cui li hai fatti. Il ripristino ora ti avvisa quando qualcosa è stato acquistato con un altro account, così sai con quale accedere.
• Piccole correzioni nel negozio.
</it-IT>
<pl-PL>
Zakupy, na których możesz polegać.

• Odnowienia Pro są teraz codziennie sprawdzane w sklepie, więc subskrypcja pozostaje aktywna.
• Masz więcej niż jedno konto? Zakupy pozostają na koncie, na którym zostały dokonane. Przywracanie informuje teraz, gdy coś kupiono na innym koncie, więc wiesz, na które się zalogować.
• Drobne poprawki w sklepie.
</pl-PL>
<pt-BR>
Compras em que você pode confiar.

• As renovações do Pro agora são conferidas com a loja todos os dias, para sua assinatura continuar ativa.
• Tem mais de uma conta? As compras ficam na conta em que você as fez. Ao restaurar, o app avisa quando algo foi comprado em outra conta, para você saber com qual entrar.
• Pequenas correções na loja.
</pt-BR>
<ru-RU>
Покупки, на которые можно положиться.

• Продления Pro теперь ежедневно сверяются с магазином, чтобы подписка оставалась активной.
• У вас несколько аккаунтов? Покупки остаются в том аккаунте, с которого они сделаны. При восстановлении приложение подскажет, если покупка сделана в другом аккаунте, — чтобы вы знали, в какой войти.
• Небольшие исправления в магазине.
</ru-RU>
<tr-TR>
Güvenebileceğin satın alımlar.

• Pro yenilemeleri artık her gün mağazayla kontrol ediliyor, böylece aboneliğin aktif kalıyor.
• Birden fazla hesabın mı var? Satın alımlar, onları yaptığın hesapta kalır. Geri yükleme artık bir şeyin başka bir hesapla satın alındığını söylüyor, böylece hangi hesapla giriş yapacağını biliyorsun.
• Mağazada küçük düzeltmeler.
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
