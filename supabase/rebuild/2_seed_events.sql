-- Real public events in Tashkent collected from public listings on 2026-11-25.
-- Run AFTER rebuild.sql. Replace the email below with the account that owns the editorial organizer.
begin;
do $$
declare owner uuid; org uuid; ev uuid; tashkent bigint;
begin
  select id into owner from auth.users where email = 'OWNER_EMAIL@example.com';
  if owner is null then raise exception 'Create this user first: Authentication > Users > Add user'; end if;
  insert into public.profiles(id) values(owner) on conflict do nothing;
  insert into public.user_roles values(owner,'organizer') on conflict do nothing;
  insert into public.organizer_profiles(owner_id,name,description,approved)
  values(owner,'EventRadar Afisha','Editorial listings of public events in Uzbekistan collected from official announcements.',true)
  on conflict (owner_id) do update set approved = true returning id into org;
  select id into tashkent from public.cities where names->>'en' = 'Tashkent';
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'music','ru','published',tashkent,'offline','Humo Arena, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','LVBEL C5 в Ташкенте','Первый концерт LVBEL C5 в Узбекистане на сцене Humo Arena. Время начала и билеты уточняйте у организатора. Источник: https://belong.events/event/lvbel-c5-11d45091-8c92-49ab-b9c0-61710b8dc7c1');
  insert into public.event_translations values(ev,'en','LVBEL C5 in Tashkent','LVBEL C5''s first ever concert in Uzbekistan at Humo Arena. Check the start time and tickets with the organizer. Source: https://belong.events/event/lvbel-c5-11d45091-8c92-49ab-b9c0-61710b8dc7c1');
  insert into public.event_translations values(ev,'uz','LVBEL C5 Toshkentda','LVBEL C5 ning O‘zbekistondagi ilk konserti Humo Arena sahnasida. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://belong.events/event/lvbel-c5-11d45091-8c92-49ab-b9c0-61710b8dc7c1');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-09 19:00+05','2026-12-09 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'music','ru','published',tashkent,'offline','Дворец киноискусства «Панорама», Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','Группа «Секрет»','Концерт группы «Секрет» в Национальном дворце киноискусства «Панорама». Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/concerts/2026/09/23/sekret-fm');
  insert into public.event_translations values(ev,'en','Sekret band concert','Concert of the band Sekret at the Panorama National Palace of Cinema. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/concerts/2026/09/23/sekret-fm');
  insert into public.event_translations values(ev,'uz','«Sekret» guruhi konserti','«Sekret» guruhining konserti «Panorama» Milliy kino san’ati saroyida. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/concerts/2026/09/23/sekret-fm');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-11 19:00+05','2026-12-11 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'music','ru','published',tashkent,'offline','Спорткомплекс «Юнусабад», Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','«Машина времени»','Большой концерт легендарной рок-группы «Машина времени» в спорткомплексе «Юнусабад». Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/concerts/2026/09/11/time-machine');
  insert into public.event_translations values(ev,'en','Mashina Vremeni (Time Machine)','A big concert by the legendary rock band Mashina Vremeni at the Yunusabad sports complex. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/concerts/2026/09/11/time-machine');
  insert into public.event_translations values(ev,'uz','«Mashina vremeni» konserti','Afsonaviy «Mashina vremeni» rok-guruhining «Yunusobod» sport majmuasidagi katta konserti. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/concerts/2026/09/11/time-machine');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-12 19:00+05','2026-12-12 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'music','ru','published',tashkent,'offline','Humo Arena, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','Любовь Успенская','Концерт одной из самых известных исполнительниц русского шансона на сцене Humo Arena. Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/concerts/2026/09/02/uspenskaya');
  insert into public.event_translations values(ev,'en','Lyubov Uspenskaya','Concert by one of the best-known Russian chanson singers at Humo Arena. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/concerts/2026/09/02/uspenskaya');
  insert into public.event_translations values(ev,'uz','Lyubov Uspenskaya','Rus shansonining eng mashhur ijrochilaridan biri Humo Arena sahnasida. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/concerts/2026/09/02/uspenskaya');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-15 19:00+05','2026-12-15 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'music','uz','published',tashkent,'offline','Humo Arena, Toshkent') returning id into ev;
  insert into public.event_translations values(ev,'uz','«Yalla» ansambli: «Sog‘inib kutgandim»','«Yalla» ansambli va Farrux Zokirovning Humo Arena’dagi konserti. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://belong.events/event/yalla-ansambli-soginib-kutgandim-0a4d4c5a-6c0f-4dc5-a356-6bad8b505df8');
  insert into public.event_translations values(ev,'ru','Ансамбль «Ялла»: «Sog‘inib kutgandim»','Концерт ансамбля «Ялла» и Фарруха Закирова в Humo Arena. Время начала и билеты уточняйте у организатора. Источник: https://belong.events/event/yalla-ansambli-soginib-kutgandim-0a4d4c5a-6c0f-4dc5-a356-6bad8b505df8');
  insert into public.event_translations values(ev,'en','Yalla ensemble: Sog‘inib kutgandim','Concert by the Yalla ensemble and Farrukh Zakirov at Humo Arena. Check the start time and tickets with the organizer. Source: https://belong.events/event/yalla-ansambli-soginib-kutgandim-0a4d4c5a-6c0f-4dc5-a356-6bad8b505df8');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-17 19:00+05','2026-12-17 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'gaming','ru','published',tashkent,'offline','Humo Arena, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','GeekCon Tashkent','Гик-фестиваль GeekCon Tashkent: два дня в Humo Arena, 19 и 20 декабря. Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/znaniya/2026/11/09/geekcon');
  insert into public.event_translations values(ev,'en','GeekCon Tashkent','GeekCon Tashkent geek festival: two days at Humo Arena, December 19–20. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/znaniya/2026/11/09/geekcon');
  insert into public.event_translations values(ev,'uz','GeekCon Tashkent','GeekCon Tashkent geek-festivali: 19–20-dekabr kunlari Humo Arena’da. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/znaniya/2026/11/09/geekcon');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-19 10:00+05','2026-12-20 20:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'music','ru','published',tashkent,'offline','Дворец «Дружба народов», Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','Bel Suono','Концерт фортепианного шоу Bel Suono во Дворце «Дружба народов». Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/concerts/2026/03/30/bel-suono');
  insert into public.event_translations values(ev,'en','Bel Suono','Bel Suono concert at the Friendship of Peoples Palace. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/concerts/2026/03/30/bel-suono');
  insert into public.event_translations values(ev,'uz','Bel Suono','Bel Suono konserti «Xalqlar do‘stligi» saroyida. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/concerts/2026/03/30/bel-suono');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-20 19:00+05','2026-12-20 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'art','ru','published',tashkent,'offline','Obi Hayot, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','Новогодний вечер Нурлана Сабурова','Новогодний вечер Нурлана Сабурова в Obi Hayot. Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/concerts/2026/11/20/saburov');
  insert into public.event_translations values(ev,'en','Nurlan Saburov New Year evening','Nurlan Saburov''s New Year evening show at Obi Hayot. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/concerts/2026/11/20/saburov');
  insert into public.event_translations values(ev,'uz','Nurlan Saburovning yangi yil kechasi','Nurlan Saburovning Obi Hayot’dagi yangi yil kechasi. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/concerts/2026/11/20/saburov');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-20 19:00+05','2026-12-20 22:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'art','ru','published',tashkent,'offline','Галерея изящных искусств (НБУ), Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','Выставка скульптора Анвара Рахматуллаева','Выставка работ скульптора Анвара Рахматуллаева в Галерее изящных искусств НБУ. До 20 декабря. Время начала и билеты уточняйте у организатора. Источник: https://www.afisha.uz/ru/exhibitions/2026/11/24/rahmatul90');
  insert into public.event_translations values(ev,'en','Sculptor Anvar Rakhmatullaev exhibition','Exhibition of works by sculptor Anvar Rakhmatullaev at the NBU Gallery of Fine Arts. Until December 20. Check the start time and tickets with the organizer. Source: https://www.afisha.uz/ru/exhibitions/2026/11/24/rahmatul90');
  insert into public.event_translations values(ev,'uz','Haykaltarosh Anvar Rahmatullayev ko‘rgazmasi','Haykaltarosh Anvar Rahmatullayev asarlari ko‘rgazmasi MBB Tasviriy san’at galereyasida. 20-dekabrgacha. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.afisha.uz/ru/exhibitions/2026/11/24/rahmatul90');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-11-25 10:00+05','2026-12-20 18:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'fashion','ru','published',tashkent,'offline','Узэкспоцентр, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','BeautyExpo Uzbekistan 2026','20-я международная специализированная выставка индустрии красоты в Узэкспоцентре. Время начала и билеты уточняйте у организатора. Источник: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_translations values(ev,'en','BeautyExpo Uzbekistan 2026','20th international specialized beauty industry exhibition at Uzexpocentre. Check the start time and tickets with the organizer. Source: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_translations values(ev,'uz','BeautyExpo Uzbekistan 2026','Go‘zallik sanoatining 20-xalqaro ixtisoslashgan ko‘rgazmasi O‘zekspomarkazda. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-09 10:00+05','2026-12-11 18:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'family','ru','published',tashkent,'offline','Узэкспоцентр, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','KinderExpo Uzbekistan 2026','Международная специализированная выставка товаров для материнства и детства. Время начала и билеты уточняйте у организатора. Источник: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_translations values(ev,'en','KinderExpo Uzbekistan 2026','International specialized exhibition of maternity and childhood products. Check the start time and tickets with the organizer. Source: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_translations values(ev,'uz','KinderExpo Uzbekistan 2026','Onalik va bolalik mahsulotlari xalqaro ixtisoslashgan ko‘rgazmasi. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2026-12-09 10:00+05','2026-12-11 18:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'fashion','en','published',tashkent,'offline','CAEx, 1 Milliy Bog Street, Tashkent') returning id into ev;
  insert into public.event_translations values(ev,'en','Tashkent Fashion & Textile Expo 2027','International fashion and textile exhibition with runway shows, B2B meetings and workshops. Check the start time and tickets with the organizer. Source: https://tftexpo.com/en');
  insert into public.event_translations values(ev,'ru','Tashkent Fashion & Textile Expo 2027','Международная выставка моды и текстиля: показы, B2B-встречи и мастер-классы. Время начала и билеты уточняйте у организатора. Источник: https://tftexpo.com/en');
  insert into public.event_translations values(ev,'uz','Tashkent Fashion & Textile Expo 2027','Moda va to‘qimachilik xalqaro ko‘rgazmasi: defilelar, B2B uchrashuvlar va master-klasslar. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://tftexpo.com/en');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2027-01-25 11:00+05','2027-01-27 20:00+05','Asia/Tashkent');
  insert into public.events(organizer_id,category_slug,original_language,status,city_id,format,address)
  values(org,'food','ru','published',tashkent,'offline','Выставочный центр CAEx, Ташкент') returning id into ev;
  insert into public.event_translations values(ev,'ru','CAEx Horeca & UzFPT 2027','3-я специализированная выставка продуктов питания, упаковки, технологий переработки и индустрии HoReCa. Время начала и билеты уточняйте у организатора. Источник: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_translations values(ev,'en','CAEx Horeca & UzFPT 2027','3rd specialized exhibition of food products, packaging, processing technologies and the HoReCa industry. Check the start time and tickets with the organizer. Source: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_translations values(ev,'uz','CAEx Horeca & UzFPT 2027','Oziq-ovqat, qadoqlash, qayta ishlash texnologiyalari va HoReCa sohasining 3-ixtisoslashgan ko‘rgazmasi. Boshlanish vaqti va chiptalarni tashkilotchidan aniqlang. Manba: https://www.advantour.com/uzbekistan/tashkent/exhibitions.htm');
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(ev,'2027-02-04 10:00+05','2027-02-06 18:00+05','Asia/Tashkent');
end $$;
commit;
