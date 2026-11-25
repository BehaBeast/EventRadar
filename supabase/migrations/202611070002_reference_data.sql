begin;
insert into public.currencies values ('UZS',2);
insert into public.countries values ('UZ','{"ru": "Узбекистан", "uz": "O‘zbekiston", "en": "Uzbekistan"}'::jsonb,'UZS');
insert into public.cities(country_code,names,timezone) values ('UZ','{"ru": "Фергана", "uz": "Farg‘ona", "en": "Fergana"}'::jsonb,'Asia/Tashkent'), ('UZ','{"ru": "Ташкент", "uz": "Toshkent", "en": "Tashkent"}'::jsonb,'Asia/Tashkent');
insert into public.categories(slug,names,position) values
('music','{"ru": "Музыка и концерты", "uz": "Musiqa va konsertlar", "en": "Music and concerts"}'::jsonb,1),
('sport','{"ru": "Спорт и фитнес", "uz": "Sport va fitnes", "en": "Sport and fitness"}'::jsonb,2),
('art','{"ru": "Искусство и культура", "uz": "San’at va madaniyat", "en": "Art and culture"}'::jsonb,3),
('business','{"ru": "Бизнес и знакомства", "uz": "Biznes va tanishuvlar", "en": "Business and networking"}'::jsonb,4),
('education','{"ru": "Образование и мастер-классы", "uz": "Ta’lim va mahorat darslari", "en": "Education and workshops"}'::jsonb,5),
('food','{"ru": "Еда и гастрономия", "uz": "Taomlar va gastronomiya", "en": "Food and gastronomy"}'::jsonb,6),
('nightlife','{"ru": "Вечеринки и ночная жизнь", "uz": "Bazmlar va tungi hayot", "en": "Parties and nightlife"}'::jsonb,7),
('technology','{"ru": "Технологии и IT", "uz": "Texnologiyalar va IT", "en": "Technology and IT"}'::jsonb,8),
('family','{"ru": "Семья и дети", "uz": "Oila va bolalar", "en": "Family and children"}'::jsonb,9),
('travel','{"ru": "Путешествия и природа", "uz": "Sayohat va tabiat", "en": "Travel and outdoors"}'::jsonb,10),
('cinema','{"ru": "Кино и театр", "uz": "Kino va teatr", "en": "Cinema and theatre"}'::jsonb,11),
('charity','{"ru": "Благотворительность и волонтёрство", "uz": "Xayriya va volontyorlik", "en": "Charity and volunteering"}'::jsonb,12),
('exhibitions','{"ru": "Выставки и ярмарки", "uz": "Ko‘rgazmalar va yarmarkalar", "en": "Exhibitions and fairs"}'::jsonb,13),
('motors','{"ru": "Автомобили и мотоспорт", "uz": "Avtomobillar va motosport", "en": "Cars and motorsport"}'::jsonb,14),
('gaming','{"ru": "Игры и киберспорт", "uz": "O‘yinlar va kibersport", "en": "Gaming and esports"}'::jsonb,15),
('fashion','{"ru": "Мода и красота", "uz": "Moda va go‘zallik", "en": "Fashion and beauty"}'::jsonb,16);
commit;
