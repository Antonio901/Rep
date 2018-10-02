﻿#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("АвтоТест") Тогда // Возврат при получении формы для анализа.
		Возврат;
	КонецЕсли;
	
	Если Не ПравоДоступа("СохранениеДанныхПользователя", Метаданные)
		Или Не ПравоДоступа("АдминистрированиеДанных", Метаданные) Тогда
		ТолькоПросмотр = Истина;
		Элементы.ОписаниеФормы.Заголовок = НСтр("ru = 'Для переноса вариантов отчетов требуются права ""Сохранение данных пользователя"" и ""Администрирование данных"".'");
		Возврат;
	КонецЕсли;
	
	Хранилище = Метаданные.ХранилищеВариантовОтчетов;
	Если Хранилище <> Неопределено И Хранилище.Имя = "ХранилищеВариантовОтчетов" Тогда
		Элементы.СохранитьВариантыОтчетов.Доступность = Ложь;
		Элементы.ЗагрузитьВариантыОтчетов.ТолькоВоВсехДействиях = Ложь;
		Элементы.ОписаниеФормы.Заголовок = Элементы.ОписаниеФормы.Заголовок + Символы.ПС + Символы.ПС
			+ НСтр("ru = 'Чтение вариантов отчетов из стандартного хранилища невозможно, поскольку хранилище подсистемы ""Варианты отчетов"" уже установлено в свойстве конфигурации ""Хранилище вариантов отчетов"".'");
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура СохранитьВариантыОтчетов(Команда)
	Результат = СохранитьВариантыОтчетовНаСервере();
	ПоказатьПредупреждение(, Результат);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьВариантыОтчетов(Команда)
	ТекстВопроса = 
	НСтр("ru = 'Загрузку вариантов отчетов следует выполнять только в том случае,
	|если сохранение не было выполнено до обновления конфигурации.
	|
	|В этом случае команду ""Загрузить варианты отчетов"" следует выполнять
	|после очистки свойства конфигурации ""Хранилище вариантов отчетов""
	|(в конфигураторе) и выполнения команды ""Сохранить варианты отчетов"".'");
	Кнопки = Новый СписокЗначений;
	Кнопки.Добавить(КодВозвратаДиалога.Да, НСтр("ru = 'Загрузить варианты отчетов'"));
	Кнопки.Добавить(КодВозвратаДиалога.Отмена);
	Обработчик = Новый ОписаниеОповещения("ЗагрузитьВариантыОтчетовЗавершение", ЭтотОбъект);
	ПоказатьВопрос(Обработчик, ТекстВопроса, Кнопки, , КодВозвратаДиалога.Отмена);
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьВариантыОтчетовЗавершение(Ответ, ДополнительныеПараметры) Экспорт
	Если Ответ = КодВозвратаДиалога.Да Тогда
		Результат = ЗагрузитьВариантыОтчетовНаСервере();
		ПоказатьПредупреждение(, Результат);
	КонецЕсли;
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Вызов сервера, Сервер

&НаСервере
Функция СохранитьВариантыОтчетовНаСервере()
	ВариантыСохранены = Ложь;
	Попытка
		ВариантыСохранены = НачатьКонвертациюВариантовОтчетов();
	Исключение
		ПредставлениеОшибки = НСтр("ru = 'При сохранении вариантов отчетов возникла ошибка:'")
		+ Символы.ПС
		+ ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ОшибкаПоВарианту(Неопределено, ПредставлениеОшибки);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ПредставлениеОшибки);
	КонецПопытки;
	
	Если ВариантыСохранены Тогда
		Результат = НСтр("ru = 'Настройки вариантов отчетов успешно сохранены.'");
	Иначе
		Результат = НСтр("ru = 'Не удалось сохранить настройки вариантов отчетов.
		|Подробности см. в окне сообщений и журнале регистрации.'");
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция ЗагрузитьВариантыОтчетовНаСервере()
	Результат = "";
	Попытка
		// ОбщегоНазначения.ВычислитьВБезопасномРежиме не может быть вызвана, 
		// так как обработка должна запускаться как внешняя.
		ОбщийМодульВариантыОтчетов = Вычислить("ВариантыОтчетов");
		Если ОбщийМодульВариантыОтчетов = Неопределено Тогда
			Результат = НСтр("ru = 'Не удалось загрузить настройки вариантов отчетов:
			|Подсистема ""Варианты отчетов"" не найдена.'");
		Иначе
			ОбщийМодульВариантыОтчетов.ЗавершитьКонвертациюВариантовОтчетов();
			Результат = НСтр("ru = 'Настройки вариантов отчетов успешно загружены.
			|Если ранее свойство конфигурации ""Хранилище вариантов отчетов"" было очищено,
			|то теперь его снова можно заполнить, выбрав одноименное хранилище настроек.'");
		КонецЕсли;
	Исключение
		ПредставлениеОшибки = НСтр("ru = 'При загрузке вариантов отчетов возникла ошибка:'")
		+ Символы.ПС
		+ ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ОшибкаПоВарианту(Неопределено, ПредставлениеОшибки);
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю(ПредставлениеОшибки);
		Результат = НСтр("ru = 'Не удалось загрузить настройки вариантов отчетов.
		|Подробности см. в окне сообщений или в журнале регистрации.'");
	КонецПопытки;
	
	Возврат Результат;
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Сервер

&НаСервере
Функция НачатьКонвертациюВариантовОтчетов()
	// Результат, который будет сохранен в хранилище.
	ТаблицаВариантов = ХранилищеОбщихНастроекЗагрузить("ПереносВариантовОтчетов", "ТаблицаВариантов", , , "");
	Если ТипЗнч(ТаблицаВариантов) <> Тип("ТаблицаЗначений") ИЛИ ТаблицаВариантов.Количество() = 0 Тогда
		ТаблицаВариантов = Новый ТаблицаЗначений;
		ТаблицаВариантов.Колонки.Добавить("Отчет",     ОписаниеТиповСтрока());
		ТаблицаВариантов.Колонки.Добавить("Вариант",   ОписаниеТиповСтрока());
		ТаблицаВариантов.Колонки.Добавить("Автор",     ОписаниеТиповСтрока());
		ТаблицаВариантов.Колонки.Добавить("Настройка", Новый ОписаниеТипов("ХранилищеЗначения"));
		ТаблицаВариантов.Колонки.Добавить("ПредставлениеОтчета",   ОписаниеТиповСтрока());
		ТаблицаВариантов.Колонки.Добавить("ПредставлениеВарианта", ОписаниеТиповСтрока());
		ТаблицаВариантов.Колонки.Добавить("ИдентификаторАвтора",   Новый ОписаниеТипов("УникальныйИдентификатор"));
	КонецЕсли;
	
	УдалятьВсе = Истина;
	МассивУдаляемыхКлючейОбъектов = Новый Массив;
	
	ВыборкаХранилища = ХранилищеВариантовОтчетов.Выбрать();
	ОшибокЧтенияПодряд = 0;
	Пока Истина Цикл
		Попытка
			ЭлементВыборкиПолучен = ВыборкаХранилища.Следующий();
			ОшибокЧтенияПодряд = 0;
		Исключение
			ЭлементВыборкиПолучен = Неопределено;
			ОшибокЧтенияПодряд = ОшибокЧтенияПодряд + 1;
			ПредставлениеОшибки = НСтр("ru = 'При выборке вариантов отчетов из стандартного хранилища возникла ошибка:'")
			+ Символы.ПС
			+ ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ОшибкаПоВарианту(Неопределено, ПредставлениеОшибки);
		КонецПопытки;
		
		Если ЭлементВыборкиПолучен = Ложь Тогда
			Прервать;
		ИначеЕсли ЭлементВыборкиПолучен = Неопределено Тогда
			Если ОшибокЧтенияПодряд > 100 Тогда
				Прервать;
			Иначе
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		// Пропуск неподключенных внутренних отчетов.
		ОтчетМетаданные = Метаданные.НайтиПоПолномуИмени(ВыборкаХранилища.КлючОбъекта);
		Если ОтчетМетаданные <> Неопределено Тогда
			ХранилищеМетаданные = ОтчетМетаданные.ХранилищеВариантов;
			Если ХранилищеМетаданные = Неопределено ИЛИ ХранилищеМетаданные.Имя <> "ХранилищеВариантовОтчетов" Тогда
				УдалятьВсе = Ложь;
				Продолжить;
			КонецЕсли;
		КонецЕсли;
		
		// Внешние варианты отчетов переносятся все, поскольку для них невозможно определить
		// подключены они к хранилищу подсистемы или нет.
		МассивУдаляемыхКлючейОбъектов.Добавить(ВыборкаХранилища.КлючОбъекта);
		
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(ВыборкаХранилища.Пользователь);
		Если ПользовательИБ = Неопределено Тогда
			Пользователь = Справочники.Пользователи.НайтиПоНаименованию(ВыборкаХранилища.Пользователь, Истина);
			Если НЕ ЗначениеЗаполнено(Пользователь) Тогда
				Продолжить;
			КонецЕсли;
			ИдентификаторПользователя = Пользователь.ИдентификаторПользователяИБ;
		Иначе
			ИдентификаторПользователя = ПользовательИБ.УникальныйИдентификатор;
		КонецЕсли;
		
		СтрокаТаблицы = ТаблицаВариантов.Добавить();
		СтрокаТаблицы.Отчет     = ВыборкаХранилища.КлючОбъекта;
		СтрокаТаблицы.Вариант   = ВыборкаХранилища.КлючНастроек;
		СтрокаТаблицы.Автор     = ВыборкаХранилища.Пользователь;
		СтрокаТаблицы.Настройка = Новый ХранилищеЗначения(ВыборкаХранилища.Настройки, Новый СжатиеДанных(9));
		СтрокаТаблицы.ПредставлениеВарианта = ВыборкаХранилища.Представление;
		СтрокаТаблицы.ИдентификаторАвтора   = ИдентификаторПользователя;
		Если ОтчетМетаданные = Неопределено Тогда
			СтрокаТаблицы.ПредставлениеОтчета = ВыборкаХранилища.КлючОбъекта;
		Иначе
			СтрокаТаблицы.ПредставлениеОтчета = ОтчетМетаданные.Представление();
		КонецЕсли;
	КонецЦикла;
	
	// Запись результата в хранилище.
	ХранилищеОбщихНастроекСохранить(
		"ПереносВариантовОтчетов", 
		"ТаблицаВариантов", 
		ТаблицаВариантов,
		,
		"");
	
	// Очистка стандартного хранилища.
	Если УдалятьВсе Тогда
		ХранилищеВариантовОтчетов.Удалить(Неопределено, Неопределено, Неопределено);
	Иначе
		Для Каждого КлючОбъекта Из МассивУдаляемыхКлючейОбъектов Цикл
			ХранилищеВариантовОтчетов.Удалить(КлючОбъекта, Неопределено, Неопределено);
		КонецЦикла;
	КонецЕсли;
	
	// Результат выполнения
	Возврат Истина;
КонецФункции

&НаСервере
Функция ЭтотОбъект()
	Возврат РеквизитФормыВЗначение("Объект");
КонецФункции

&НаСервере
Процедура ХранилищеОбщихНастроекСохранить(КлючОбъекта, КлючНастроек, Значение = Неопределено,
	ОписаниеНастроек = Неопределено, ИмяПользователя = Неопределено)
	ХранилищеОбщихНастроек.Сохранить(КлючОбъекта, КлючНастроек, Значение, ОписаниеНастроек, ИмяПользователя);
КонецПроцедуры

&НаСервере
Функция ХранилищеОбщихНастроекЗагрузить(КлючОбъекта, КлючНастроек, ЗначениеПоУмолчанию = Неопределено, 
	ОписаниеНастроек = Неопределено, ИмяПользователя = Неопределено)
	
	Результат = ХранилищеОбщихНастроек.Загрузить(КлючОбъекта, КлючНастроек, ОписаниеНастроек, ИмяПользователя);
	
	Если (Результат = Неопределено) И (ЗначениеПоУмолчанию <> Неопределено) Тогда
		Результат = ЗначениеПоУмолчанию;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

&НаСервере
Функция ОписаниеТиповСтрока(ДлинаСтроки = 1000)
	Возврат Новый ОписаниеТипов("Строка", , Новый КвалификаторыСтроки(ДлинаСтроки));
КонецФункции

&НаСервере
Процедура ОшибкаПоВарианту(Вариант, Сообщение, Реквизит1 = Неопределено, Реквизит2 = Неопределено, Реквизит3 = Неопределено)
	Уровень = УровеньЖурналаРегистрации.Ошибка;
	ЗаписьЖурнала(Уровень, Вариант, Сообщение, Реквизит1, Реквизит2, Реквизит3);
КонецПроцедуры

&НаСервере
Процедура ЗаписьЖурнала(Уровень, Ссылка, Текст, Параметр1 = Неопределено, Параметр2 = Неопределено, Параметр3 = Неопределено)
	Текст = СтрЗаменить(Текст, "%1", Параметр1); // Переход на СтрШаблон невозможен.
	Текст = СтрЗаменить(Текст, "%2", Параметр2);
	Текст = СтрЗаменить(Текст, "%3", Параметр3);
	ЗаписьЖурналаРегистрации(
		НСтр("ru = 'Перенос вариантов отчетов'", ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
		Уровень,
		ЭтотОбъект().Метаданные(),
		Ссылка,
		Текст);
КонецПроцедуры

#КонецОбласти
