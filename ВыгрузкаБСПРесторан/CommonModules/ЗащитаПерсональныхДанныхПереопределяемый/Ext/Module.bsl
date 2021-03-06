﻿#Область ПрограммныйИнтерфейс

// Обеспечивает сбор сведений о хранении данных, относящихся к персональным.
//
// Параметры:
//		ТаблицаСведений - ТаблицаЗначений - таблица с полями:
//			* Объект 			- Строка - полное имя объекта метаданных;
//			* ПоляРегистрации	- Строка - имена полей регистрации, отдельные поля регистрации отделяются запятой,
//										альтернативные - символом "|";
//			* ПоляДоступа		- Строка - имена полей доступа через запятую.
//			* ОбластьДанных		- Строка - идентификатор области данных, необязательно для заполнения.
//
Процедура ЗаполнитьСведенияОПерсональныхДанных(ТаблицаСведений) Экспорт
	
	НовыеСведения = ТаблицаСведений.Добавить();
	НовыеСведения.Объект			= "Справочник.ФизическиеЛица";
	НовыеСведения.ПоляРегистрации	= "Ссылка";
	НовыеСведения.ПоляДоступа		= "ДатаРождения";
	НовыеСведения.ОбластьДанных		= "ЛичныеДанные";
	
	НовыеСведения = ТаблицаСведений.Добавить();
	НовыеСведения.Объект			= "Справочник.ФизическиеЛица";
	НовыеСведения.ПоляРегистрации	= "Ссылка";
	НовыеСведения.ПоляДоступа		= "СерияДокумента,НомерДокумента,КемВыданДокумент,ДатаВыдачиДокумента";
	НовыеСведения.ОбластьДанных		= "ПаспортныеДанные";

	
КонецПроцедуры

// Обеспечивает составление коллекции областей персональных данных.
//
// Параметры:
//		ОбластиПерсональныхДанных - ТаблицаЗначений - таблица с полями:
//			* Имя			- Строка - идентификатор области данных.
//			* Представление	- Строка - пользовательское представление области данных.
//			* Родитель		- Строка - идентификатор родительской области данных.
//
Процедура ЗаполнитьОбластиПерсональныхДанных(ОбластиПерсональныхДанных) Экспорт
	

	// Заполнение представлений для используемых областей.
	НоваяОбласть = ОбластиПерсональныхДанных.Добавить();
	НоваяОбласть.Имя = "ЛичныеДанные";
	НоваяОбласть.Представление = НСтр("ru = 'Личные данные'");
	
	НоваяОбласть = ОбластиПерсональныхДанных.Добавить();
	НоваяОбласть.Имя = "ПаспортныеДанные";
	НоваяОбласть.Представление = НСтр("ru = 'Паспортные данные'");
	НоваяОбласть.Родитель = "ЛичныеДанные";
	
КонецПроцедуры

// Вызывается при заполнении формы "Согласие на обработку персональных данных" данными, 
// переданных в качестве параметров, субъектов.
//
// Параметры:
//		СубъектыПерсональныхДанных 	- ДанныеФормыКоллекция - содержит сведения о субъектах.
//		ДатаАктуальности			- Дата - дата, на которую нужно заполнить сведения.
//
Процедура ДополнитьДанныеСубъектовПерсональныхДанных(СубъектыПерсональныхДанных, ДатаАктуальности) Экспорт
	
	// Пример заполнения данных для субъектов типов: Физические лица, КонтактныеЛицаПартнеров, Контрагенты,
	// Партнеры.
	Для Каждого СтрокаСубъект Из СубъектыПерсональныхДанных Цикл
		Если ТипЗнч(СтрокаСубъект.Субъект) = Тип("СправочникСсылка.ФизическиеЛица") Тогда
			ИменаРеквизитов = "Наименование, СерияДокумента, НомерДокумента, КемВыданДокумент, ДатаВыдачиДокумента";
			ЗначенияРеквизитов = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(СтрокаСубъект.Субъект, ИменаРеквизитов);
			// Заполнение реквизитов.
			СтрокаСубъект.ФИО = ЗначенияРеквизитов.Наименование;
			Если ЗначениеЗаполнено(ЗначенияРеквизитов.СерияДокумента)
				Или ЗначениеЗаполнено(ЗначенияРеквизитов.НомерДокумента)
				Или ЗначениеЗаполнено(ЗначенияРеквизитов.КемВыданДокумент)
				Или ЗначениеЗаполнено(ЗначенияРеквизитов.ДатаВыдачиДокумента) Тогда
				СтрокаСубъект.ПаспортныеДанные = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Серия %1, номер %2, выдан %3 %4'"), 
					ЗначенияРеквизитов.СерияДокумента, 
					ЗначенияРеквизитов.НомерДокумента, 
					ЗначенияРеквизитов.КемВыданДокумент, 
					Формат(ЗначенияРеквизитов.ДатаВыдачиДокумента, "ДЛФ=D"));
			КонецЕсли;
		ИначеЕсли ТипЗнч(СтрокаСубъект.Субъект) = Тип("СправочникСсылка.КонтактныеЛицаПартнеров") Тогда
			ФизическоеЛицо = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаСубъект.Субъект, "ФизическоеЛицо");
			СтрокаСубъект.ФИО = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(ФизическоеЛицо, "Наименование");
			СтрокаСубъект.Адрес = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(СтрокаСубъект.Субъект, Справочники.ВидыКонтактнойИнформации.АдресКонтактногоЛица);
		ИначеЕсли ТипЗнч(СтрокаСубъект.Субъект) = Тип("СправочникСсылка.Контрагенты") Тогда	
			СтрокаСубъект.ФИО = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаСубъект.Субъект, "Наименование");
			СтрокаСубъект.Адрес = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(СтрокаСубъект.Субъект, Справочники.ВидыКонтактнойИнформации.АдресКонтрагента);
		ИначеЕсли ТипЗнч(СтрокаСубъект.Субъект) = Тип("СправочникСсылка.Партнеры") Тогда	
			СтрокаСубъект.ФИО = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СтрокаСубъект.Субъект, "Наименование");
			СтрокаСубъект.Адрес = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(СтрокаСубъект.Субъект, Справочники.ВидыКонтактнойИнформации.АдресПартнера);
		КонецЕсли;
	КонецЦикла;

	
КонецПроцедуры

// Вызывается при заполнении формы "Согласие на обработку персональных данных" данными организации.
//
// Параметры:
//		Организация					- ОпределяемыйТип.Организация - оператор персональных данных.
//		ДанныеОрганизации			- Структура - данные об организации (адрес, ФИО ответственного и т.д.).
//		ДатаАктуальности			- Дата      - дата, на которую нужно заполнить сведения.
//
Процедура ДополнитьДанныеОрганизацииОператораПерсональныхДанных(Организация, ДанныеОрганизации, ДатаАктуальности) Экспорт
	

	ДанныеОрганизации.Вставить("НаименованиеОрганизации", ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Организация, "НаименованиеПолное"));
	ДанныеОрганизации.Вставить("АдресОрганизации", 
		УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъекта(Организация, Справочники.ВидыКонтактнойИнформации.ЮридическийАдресОрганизации, ДатаАктуальности));


КонецПроцедуры

#КонецОбласти
