﻿
#Область СлужебныйПрограммныйИнтерфейс

// Формирует структуру таблиц проверок и групп проверок для дальнейшего использования.
//
// Возвращаемое значение:
//    Структура со значениями:
//       * ГруппыПроверок - ТаблицаЗначений - Таблица групп проверок.
//       * Проверки       - ТаблицаЗначений - Таблица проверок.
//
Функция ПроверкиВеденияУчета() Экспорт
	
	ГруппыПроверок = НоваяТаблицаГруппПроверок();
	Проверки       = НоваяТаблицаПроверок();
	
	СистемныеПроверкиВеденияУчета(ГруппыПроверок, Проверки);
	
	КонтрольВеденияУчетаПереопределяемый.ПриОпределенииПроверок(ГруппыПроверок, Проверки);
	КонтрольВеденияУчетаПереопределяемый.ПриОпределенииПрикладныхПроверок(ГруппыПроверок, Проверки);
	
	ОбеспечитьОбратнуюСовместимость(Проверки);
	
	Возврат Новый ФиксированнаяСтруктура("ГруппыПроверок, Проверки", ГруппыПроверок, Проверки);
	
КонецФункции

// Возвращает массив типов, включающий в себя все возможные объектные типы конфигурации.
//
// Возвращаемое значение:
//    Массив - Массив объектных типов.
//
Функция ОписаниеТипаВсеОбъекты() Экспорт
	
	МассивТипов = Новый Массив;
	
	МассивВидовМетаданных = Новый Массив;
	МассивВидовМетаданных.Добавить(Метаданные.Документы);
	МассивВидовМетаданных.Добавить(Метаданные.Справочники);
	МассивВидовМетаданных.Добавить(Метаданные.ПланыОбмена);
	МассивВидовМетаданных.Добавить(Метаданные.ПланыВидовХарактеристик);
	МассивВидовМетаданных.Добавить(Метаданные.ПланыСчетов);
	МассивВидовМетаданных.Добавить(Метаданные.ПланыВидовРасчета);
	МассивВидовМетаданных.Добавить(Метаданные.Задачи);
	
	Для Каждого ВидМетаданных Из МассивВидовМетаданных Цикл
		Для Каждого ОбъектМетаданных Из ВидМетаданных Цикл
			
			РазделенноеИмя = СтрРазделить(ОбъектМетаданных.ПолноеИмя(), ".");
			Если РазделенноеИмя.Количество() < 2 Тогда
				Продолжить;
			КонецЕсли;
			
			МассивТипов.Добавить(Тип(РазделенноеИмя.Получить(0) + "Объект." + РазделенноеИмя.Получить(1)));
			
		КонецЦикла;
	КонецЦикла;
	
	Возврат Новый ФиксированныйМассив(МассивТипов);
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// См. КонтрольВеденияУчетаПереопределяемый.ПриОпределенииПроверок
Процедура СистемныеПроверкиВеденияУчета(ГруппыПроверок, Проверки)
	
	ГруппаПроверок = ГруппыПроверок.Добавить();
	ГруппаПроверок.Наименование  = НСтр("ru='Системные проверки'");
	ГруппаПроверок.Идентификатор = "СистемныеПроверки";
	
	Проверка = Проверки.Добавить();
	Проверка.ИдентификаторГруппы          = "СистемныеПроверки";
	Проверка.Наименование                 = НСтр("ru='Проверка незаполненных обязательных реквизитов'");
	Проверка.Причины                      = НСтр("ru='Некорректная синхронизация данных с другими программами или импорт данных.'");
	Проверка.Рекомендация                 = НСтр("ru='Правильно настроить синхронизацию данных и заполнить обязательные реквизиты.
	|В случае обнаружения незаполненных обязательных полей у регистров, то в большинстве
	|случаев, для устранения проблемы, требуется заполнение соответствующих полей в документе-регистраторе'");
	Проверка.Идентификатор                = "ПроверкаНезаполненныхОбязательныхРеквизитов";
	Проверка.ОбработчикПроверки           = "КонтрольВеденияУчетаСлужебный.ПроверитьНезаполненныеОбязательныеРеквизиты";
	Проверка.КонтекстПроверокВеденияУчета = "СистемныеПроверки";
	
	Проверка = Проверки.Добавить();
	Проверка.ИдентификаторГруппы          = "СистемныеПроверки";
	Проверка.Наименование                 = НСтр("ru='Проверка ссылочной целостности'");
	Проверка.Причины                      = НСтр("ru='Некорректная синхронизация данных с другими программами или импорт данных.'");
	Проверка.Рекомендация                 = НСтр("ru='• Завершить работу всех пользователей и установить блокировку входа в программу;
	|• Сделать резервную копию информационной базы;
	|• Запустить конфигуратор, меню Администрирование, Тестирования и исправление, включив два флажка для проверка логической и ссылочной целостности
	|	см подробнее на ИТС https://its.1c.ru/db/v839doc#bookmark:adm:TI000000142
	|• Снять блокировку входа в программу
	|Если работа ведется в распределенной информационной базе (РИБ), то исправление следует запускать только в главном узле.
	|	Затем выполнить синхронизацию с подчиненными узлами.
	|В случае обнаружения битых ссылок в регистрах, то в большинстве случаев, для устранения проблемы,
	|требуется устранения соответствующих битых ссылок в документе-регистраторе'");
	Проверка.Идентификатор                = "ПроверкаСсылочнойЦелостности";
	Проверка.ОбработчикПроверки           = "КонтрольВеденияУчетаСлужебный.ПроверитьСсылочнуюЦелостность";
	Проверка.КонтекстПроверокВеденияУчета = "СистемныеПроверки";
	
	Проверка = Проверки.Добавить();
	Проверка.ИдентификаторГруппы            = "СистемныеПроверки";
	Проверка.Наименование                   = НСтр("ru='Проверка циклических ссылок'");
	Проверка.Причины                        = НСтр("ru='Некорректная синхронизация данных с другими программами или импорт данных.'");
	Проверка.Рекомендация                   = НСтр("ru='• Завершить работу всех пользователей и установить блокировку входа в программу;
	|• Сделать резервную копию информационной базы;
	|• Запустить конфигуратор, меню Администрирование, Тестирования и исправление, включив два флажка для проверка логической и ссылочной целостности
	|	см подробнее на ИТС: https://its.1c.ru/db/v839doc#bookmark:adm:TI000000142
	|• Снять блокировку входа в программу
	|Если работа ведется в распределенной информационной базе (РИБ), то исправление следует запускать только в главном узле.
	|	Затем выполнить синхронизацию с подчиненными узлами 1.'");
	Проверка.Идентификатор                  = "ПроверкаЦиклическихСсылок";
	Проверка.ОбработчикПроверки             = "КонтрольВеденияУчетаСлужебный.ПроверитьЦиклическиеСсылки";
	Проверка.ОбработчикПереходаКИсправлению = "Отчет.РезультатыПроверкиУчета.Форма.ИсправлениеЦиклическихСсылок";
	Проверка.КонтекстПроверокВеденияУчета   = "СистемныеПроверки";
	
	Проверка = Проверки.Добавить();
	Проверка.ИдентификаторГруппы          = "СистемныеПроверки";
	Проверка.Наименование                 = НСтр("ru='Проверка отсутствующих предопределенных элементов'");
	Проверка.Причины                      = НСтр("ru='Некорректная синхронизация данных с другими программами или импорт данных.'");
	Проверка.Рекомендация                 = НСтр("ru='• Запустить исправление по ссылке ниже. 
		|Если работа ведется в распределенной информационной базе (РИБ), то исправление следует запускать только в главном узле.
		|	Затем выполнить синхронизацию с подчиненными узлами.'");
	Проверка.Идентификатор                = "ПроверкаОтсутствующихПредопределенныхЭлементов";
	Проверка.ОбработчикПроверки           = "КонтрольВеденияУчетаСлужебный.ПроверитьОтсутствующиеПредопределенныеЭлементы";
	Проверка.КонтекстПроверокВеденияУчета = "СистемныеПроверки";
	
	Проверка = Проверки.Добавить();
	Проверка.ИдентификаторГруппы          = "СистемныеПроверки";
	Проверка.Наименование                 = НСтр("ru='Проверка дублирования предопределенных элементов'");
	Проверка.Причины                      = НСтр("ru='Некорректная синхронизация данных с другими программами или импорт данных.'");
	Проверка.Рекомендация                 = НСтр("ru='• Запустить поиск и удаление дублей по ссылке ниже. 
		|Если работа ведется в распределенной информационной базе (РИБ), то исправление следует запускать только в главном узле.
		|	Затем выполнить синхронизацию с подчиненными узлами.'");
	Проверка.Идентификатор                = "ПроверкаДублированияПредопределенныхЭлементов";
	Проверка.ОбработчикПроверки           = "КонтрольВеденияУчетаСлужебный.ПроверитьДублированиеПредопределенныхЭлементов";
	Проверка.КонтекстПроверокВеденияУчета = "СистемныеПроверки";
	
	Проверка = Проверки.Добавить();
	Проверка.ИдентификаторГруппы          = "СистемныеПроверки";
	Проверка.Наименование                 = НСтр("ru='Проверка отсутствия предопределенных узлов плана обмена'");
	Проверка.Причины                      = НСтр("ru='Некорректное поведение программы при работе на устаревших версиях платформы 1С:Предприятие.'");
	Проверка.Рекомендация                 = НСтр("ru='• Перейти на версию платформы 1С:Предприятие 8.3.9.2033 или выше;
		|• Завершить работу всех пользователей и установить блокировку входа в программу;
		|• Сделать резервную копию информационной базы;
		|• Запустить конфигуратор, меню Администрирование, Тестирования и исправление, включив два флажка для проверка логической и ссылочной целостности
		|	см подробнее на ИТС: https://its.1c.ru/db/v839doc#bookmark:adm:TI000000142
		|• Снять блокировку входа в программу
		|Если работа ведется в распределенной информационной базе (РИБ), то исправление следует запускать только в главном узле.
		|	Затем выполнить синхронизацию с подчиненными узлами.'");
	Проверка.Идентификатор                = "ПроверкаОтсутствияПредопределенныхУзловПлановОбмена";
	Проверка.ОбработчикПроверки           = "КонтрольВеденияУчетаСлужебный.ПроверитьНаличиеПредопределенныхУзловПлановОбмена";
	Проверка.КонтекстПроверокВеденияУчета = "СистемныеПроверки";
	
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаСФайлами") Тогда
		
		Проверка = Проверки.Добавить();
		Проверка.ИдентификаторГруппы          = "СистемныеПроверки";
		Проверка.Наименование                 = НСтр("ru='Поиск ссылок на несуществующие файлы в томах хранения'");
		Проверка.Причины                      = НСтр("ru='Файл был физически удален или перемещен на диске в следствие работы антивирусных программа,
		|	непреднамеренных действий администратора и.т.д.'");
		Проверка.Рекомендация                 = НСтр("ru='• Либо пометить файл в программе на удаление;
		|• Либо восстановить файл на диске в томе из резервной копии.'");
		Проверка.Идентификатор                = "ПроверкаСсылокНаНесуществующиеФайлыВТоме";
		Проверка.ОбработчикПроверки           = "РаботаСФайламиСлужебный.ПроверкаСсылокНаНесуществующиеФайлыВТоме";
		Проверка.КонтекстПроверокВеденияУчета = "СистемныеПроверки";
		
	КонецЕсли;
	
КонецПроцедуры

// Создает таблицу групп проверок
//
// Возвращаемое значение:
//   ТаблицаЗначений с колонками:
//      * Наименование  - Строка - Наименование группы проверок.
//      * Идентификатор - Строка - Строковый идентификатор группы проверок.
//
Функция НоваяТаблицаГруппПроверок()
	
	ГруппыПроверок        = Новый ТаблицаЗначений;
	КолонкиГруппыПроверок = ГруппыПроверок.Колонки;
	КолонкиГруппыПроверок.Добавить("Наименование",  Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(256)));
	КолонкиГруппыПроверок.Добавить("Идентификатор", Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(256)));
	
	Возврат ГруппыПроверок;
	
КонецФункции

// Создает таблицу проверок.
//
// Возвращаемое значение:
//   ТаблицаЗначений - с колонками:
//      * ИдентификаторГруппы                    - Строка - Строковый идентификатор группы проверок, например: 
//                                                 "СистемныеПроверки", "ЗакрытиеМесяца", "ПроверкиНДС" и т.п.
//                                                 Обязателен для заполнения.
//      * Наименование                           - Строка - Наименование проверки, выводимое пользователю.
//      * Причины                                - Строка - Описание возможных причин, которые приводят к возникновению
//                                                 проблемы.
//      * Рекомендация                           - Строка - Рекомендация по решению возникшей проблемы.
//      * Идентификатор                          - Строка - Строковый идентификатор элемента. Обязателен для заполнения.
//      * ДатаНачалаПроверки                     - Дата - Пороговая дата, обозначающая границу проверяемых
//                                                 объектов (только для объектов с датой). Объекты, дата которых меньше
//                                                 указанной, не следует проверять. По умолчанию не заполнено (т.е.
//                                                 проверять все).
//      * ЛимитПроблем                           - Число - Количество проверяемых объектов. По умолчанию 1000. 
//                                                 Если указан 0, то следует проверять все объекты.
//      * ОбработчикПроверки                     - Строка - Имя экспортной процедуры-обработчика серверного общего 
//                                                 модуля в виде ИмяМодуля.ИмяПроцедуры. 
//      * ОбработчикПереходаКИсправлению         - Строка - Имя экспортной процедуры-обработчика клиентского общего 
//                                                 модуля для перехода к исправлению проблемы в виде ИмяМодуля.ИмяПроцедуры.
//      * БезОбработчикаПроверки                 - Булево - признак служебной проверки, которая не имеет процедуры-обработчика.
//      * ЗапрещеноИзменениеВажности             - Булево - Если Истина, то администратор не сможет перенастраивать 
//                                                 важность данной проверки.
//      * КонтекстПроверокВеденияУчета           - ОпределяемыйТип.КонтекстПроверокВеденияУчета - значение, дополнительно 
//                                                 уточняющее принадлежность проверки ведения учета к определенной группе 
//                                                 или категории.
//      * УточнениеКонтекстаПроверокВеденияУчета - ОпределяемыйТип.УточнениеКонтекстаПроверокВеденияУчета - второе значение, 
//                                                 дополнительно уточняющее принадлежность проверки ведения учета 
//                                                 к определенной группе или категории.
//      * ДополнительныеПараметры                - ХранилищеЗначений - Дополнительная информация о проверке для программного
//                                                 использования.
//
Функция НоваяТаблицаПроверок()
	
	Проверки        = Новый ТаблицаЗначений;
	КолонкиПроверок = Проверки.Колонки;
	КолонкиПроверок.Добавить("ИдентификаторГруппы",                    Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(256)));
	КолонкиПроверок.Добавить("Наименование",                           Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(256)));
	КолонкиПроверок.Добавить("Причины",                                Новый ОписаниеТипов("Строка"));
	КолонкиПроверок.Добавить("Рекомендация",                           Новый ОписаниеТипов("Строка"));
	КолонкиПроверок.Добавить("Идентификатор",                          Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(256)));
	КолонкиПроверок.Добавить("ДатаНачалаПроверки",                     Новый ОписаниеТипов("Дата", , , , , Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя)));
	КолонкиПроверок.Добавить("ЛимитПроблем",                           Новый ОписаниеТипов("Число", , , Новый КвалификаторыЧисла(8, 0, ДопустимыйЗнак.Неотрицательный)));
	КолонкиПроверок.Добавить("ОбработчикПроверки",                     Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(128)));
	КолонкиПроверок.Добавить("ОбработчикПереходаКИсправлению",         Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(128)));
	КолонкиПроверок.Добавить("БезОбработчикаПроверки",                 Новый ОписаниеТипов("Булево"));
	КолонкиПроверок.Добавить("ЗапрещеноИзменениеВажности",             Новый ОписаниеТипов("Булево"));
	КолонкиПроверок.Добавить("КонтекстПроверокВеденияУчета",           Метаданные.ОпределяемыеТипы.КонтекстПроверокВеденияУчета.Тип);
	КолонкиПроверок.Добавить("УточнениеКонтекстаПроверокВеденияУчета", Метаданные.ОпределяемыеТипы.УточнениеКонтекстаПроверокВеденияУчета.Тип);
	КолонкиПроверок.Добавить("ДополнительныеПараметры",                Новый ОписаниеТипов("ХранилищеЗначения"));
	КолонкиПроверок.Добавить("ИдентификаторРодителя",                  Новый ОписаниеТипов("Строка", , , , Новый КвалификаторыСтроки(256)));
	
	Возврат Проверки;
	
КонецФункции

Процедура ОбеспечитьОбратнуюСовместимость(Проверки)
	
	Для Каждого Проверка Из Проверки Цикл
		
		Если ЗначениеЗаполнено(Проверка.ИдентификаторГруппы) Тогда
			Продолжить;
		КонецЕсли;
		
		Проверка.ИдентификаторГруппы = Проверка.ИдентификаторРодителя;
		
	КонецЦикла;
	
КонецПроцедуры

#КонецОбласти