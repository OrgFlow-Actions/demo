//
//This class contains Unit tests for classes which provides Soql-utilities.
//
//Used abbreviations:
//- UT: unit tests
//Author: Gennadiy Pervukhin [Cervello] (13-11-2014)
@IsTest
private class DC_UT_SoqlUtils
{
	//
	//Test methods for 'DC_SoqlUtils' class
	//
	//this method tests exceptional cases in private methods
	@IsTest
	private static void test_SoqlUtils_privateMethods()
	{
		//1) getSoqlRepresentation
		try
		{
			DC_SoqlUtils.getSoqlRepresentation(null);
			System.assert(false);
		}
		catch (DC_CustomException error)
		{
			System.assert(true);
		}
		
		//2) callDmlOperation
		try
		{
			DC_SoqlUtils.callDmlOperation(null, null);
			System.assert(false);
		}
		catch (DC_CustomException error)
		{
			System.assert(true);
		}
	}
	
	@IsTest
	private static void test_SoqlUtils_joinStringsForINSection()
	{
		System.assertEquals(null, DC_SoqlUtils.joinStringsForINSection(null));
		System.assertEquals(null, DC_SoqlUtils.joinStringsForINSection(new String[]{null, ''}));
		
		String result = DC_SoqlUtils.joinStringsForINSection(new String[] {'id1', 'id2'});
		System.assert('\'id1\',\'id2\'' == result || '\'id2\',\'id1\'' == result, result);
		System.assertEquals('\'id1\'', DC_SoqlUtils.joinStringsForINSection(new String[] {'id1'}));
	}
	
	@IsTest
	private static void test_SoqlUtils_joinConditions()
	{
		String result = DC_SoqlUtils.joinConditions(new String[]{'','',''},
			DC_SoqlEnums.LogicOperator.AND_Operator);
		System.assertEquals(null, result);
		
		result = DC_SoqlUtils.joinConditions(null, DC_SoqlEnums.LogicOperator.AND_Operator);
		System.assertEquals(null, result);
		
		result = DC_SoqlUtils.joinConditions(new String[]{null, 'condition1', 'condition2'},
			DC_SoqlEnums.LogicOperator.AND_Operator);
		System.assert('(condition1) AND (condition2)' == result
			|| '(condition2) AND (condition1)' == result);
		
		result = DC_SoqlUtils.joinConditions(new String[]{null, '', 'condition'},
			DC_SoqlEnums.LogicOperator.AND_Operator);
		System.assertEquals('(condition)', result);
		
		result = DC_SoqlUtils.joinConditions(new String[]{'condition1', '', 'condition3'},
			DC_SoqlEnums.LogicOperator.OR_Operator);
		System.assert('(condition1) OR (condition3)' == result
			|| '(condition3) OR (condition1)' == result);
	}
	
	@IsTest
	private static void test_SoqlUtils_joinFields()
	{
		//INCORRECT PARAMETERS
		System.assertEquals(null, DC_SoqlUtils.joinFields(null));
		System.assertEquals(DC_StringUtils.EMPTY_STRING, DC_SoqlUtils.joinFields(new String[0]));
		
		//CORRECT PARAMETERS
		String result = DC_SoqlUtils.joinFields(new String[] {'Field1', 'Field2', 'Field3'});
		System.assertEquals('Field1, Field2, Field3', result);
	}
	
	@IsTest
	private static void test_SoqlUtils_selectCorrectValuesForInClause()
	{
		//INCORRECT PARAMETERS
		System.assertEquals(null, DC_SoqlUtils.selectCorrectValuesForInClause(null));
		
		//CORRECT PARAMETERS
		String[] selectedValues = DC_SoqlUtils.selectCorrectValuesForInClause(new String[] {
			'Field'.repeat(1000), 'Field1', 'Field3'});
		System.assertEquals(2, selectedValues.size());
		System.assertEquals('Field1', selectedValues[0]);
		System.assertEquals('Field3', selectedValues[1]);
	}
	
	@IsTest
	private static void test_SoqlUtils_formatDateTime()
	{
		DateTime dt = DateTime.newInstanceGmt(2012, 4, 15, 14, 28, 55);
		System.assertEquals('2012-04-15T14:28:55Z', DC_SoqlUtils.formatDateTime(dt));
		
		dt = null;
		System.assertEquals(null, DC_SoqlUtils.formatDateTime(dt));
	}
	
	@IsTest
	private static void test_SoqlUtils_formatDateTime2()
	{
		Date dt = null;
		System.assertEquals(null, DC_SoqlUtils.formatDateTime(dt));
		
		dt = Date.newInstance(2012, 4, 15);
		System.assertEquals('2012-04-15T00:00:00Z', DC_SoqlUtils.formatDateTime(dt));
	}
	
	@IsTest
	private static void test_SoqlUtils_formatDate()
	{
		Date date1 = Date.newInstance(2012, 4, 15);
		DateTime datetime1 = DateTime.newInstance(2012, 4, 15, 14, 28, 55);
		
		System.assertEquals('2012-04-15', DC_SoqlUtils.formatDate(date1));
		System.assertEquals('2012-04-15', DC_SoqlUtils.formatDate(datetime1));
		date1 = null;
		System.assertEquals(null, DC_SoqlUtils.formatDate(date1));
		datetime1 = null;
		System.assertEquals(null, DC_SoqlUtils.formatDate(datetime1));
	}
	
	@IsTest
	private static void test_SoqlUtils_escapeValueForEqualityOperator()
	{
		//wrong parameters
		System.assertEquals(null, DC_SoqlUtils.escapeValueForEqualityOperator(null));
		
		//good parameters
		String sourceString = 'Part1\'Part2';
		System.assertEquals(String.escapeSingleQuotes(sourceString),
			DC_SoqlUtils.escapeValueForEqualityOperator(sourceString));
	}
	
	@IsTest
	private static void test_SoqlUtils_escapeValueForLikeOperator()
	{
		//wrong parameters
		System.assertEquals(null, DC_SoqlUtils.escapeValueForLikeOperator(null));
		
		//good parameters
		//create source string
		String sourceString = 'Part';
		for (String specialChar : DC_SoqlUtils.SPECIAL_CHARS_FOR_LIKE_OPERATOR)
		{
			sourceString += specialChar + 'Part';
		}
		
		//perform operation
		String escapedString = DC_SoqlUtils.escapeValueForLikeOperator(sourceString);
		
		//remove escaped subsequences
		for (String specialChar : DC_SoqlUtils.SPECIAL_CHARS_FOR_LIKE_OPERATOR)
		{
			escapedString = escapedString.replace('\\' + specialChar, '');
		}
		//check that there are no free special chars in escaped string
		for (String specialChar : DC_SoqlUtils.SPECIAL_CHARS_FOR_LIKE_OPERATOR)
		{
			System.assert(!escapedString.contains(specialChar));
		}
	}
	
	@IsTest
	private static void test_SoqlUtils_tryPerformDmlOperation_SingleObject()
	{
		//disable all triggers to optimize creation of test data
		DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
		
		//INCORRECT DATA
		sObject testNullObject = null;
		System.assertEquals(false, DC_SoqlUtils.tryPerformDmlOperation(null, testNullObject));
		System.assertEquals(false, DC_SoqlUtils.tryPerformDmlOperation(
			DC_SoqlEnums.DmlOperation.Inserting, new User()));
		
		//CORRECT DATA
		//create test data
		Event testEvent = DC_UT_DataUtils.generateEvent('Event-1_1', DateTime.now(),
			DateTime.now().addHours(1));
		
		//INSERT data
		System.assert(testEvent.Id == null);
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Inserting, testEvent));
		System.assert(testEvent.Id != null);
		
		//UPDATE object
		String newSubject = 'Event-1_2';
		testEvent.Subject = newSubject;
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Updating, testEvent));
		
		Event updatedEvent = DC_EventDAO.getEventById(testEvent.Id);
		System.assertEquals(newSubject, updatedEvent.Subject);
		
		//UPSERT object
		newSubject = 'Event-1_3';
		testEvent.Subject = newSubject;
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Upserting, testEvent));
		updatedEvent = DC_EventDAO.getEventById(testEvent.Id);
		System.assertEquals(newSubject, updatedEvent.Subject);
		
		//DELETE object
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Deleting, testEvent));
		System.assert(DC_EventDAO.getEventById(testEvent.Id) == null);
		
		//UNDELETE object
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Undeleting, testEvent));
		System.assertEquals(testEvent.Id, DC_EventDAO.getEventById(testEvent.Id).Id);
	}
	
	@IsTest
	private static void test_SoqlUtils_tryPerformDmlOperation_ObjectsList()
	{
		//disable all triggers to optimize creation of test data
		DC_SettingsUtils.setTriggersSettingForCurrentRequest(false);
		
		//INCORRECT DATA
		sObject[] testNullObjects = null;
		System.assertEquals(false, DC_SoqlUtils.tryPerformDmlOperation(null, testNullObjects));
		
		//CORRECT DATA
		//create test data
		Event testEvent = DC_UT_DataUtils.generateEvent('Event-1_1', DateTime.now(),
			DateTime.now().addHours(1));
		
		//INSERT data
		System.assert(testEvent.Id == null);
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Inserting,
			new Event[] {testEvent}));
		System.assert(testEvent.Id != null);
		
		//UPDATE object
		String newSubject = 'Event-1_2';
		testEvent.Subject = newSubject;
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Updating,
			new Event[] {testEvent}));
		
		Event updatedEvent = DC_EventDAO.getEventById(testEvent.Id);
		
		//UPSERT object
		newSubject = 'Event-1_3';
		testEvent.Subject = newSubject;
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Upserting,
			new Event[] {testEvent}));
		updatedEvent = DC_EventDAO.getEventById(testEvent.Id);
		
		//DELETE object
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Deleting,
			new Event[] {testEvent}));
		System.assert(DC_EventDAO.getEventById(testEvent.Id) == null);
		
		//UNDELETE object
		System.assert(DC_SoqlUtils.tryPerformDmlOperation(DC_SoqlEnums.DmlOperation.Undeleting,
			new Event[] {testEvent}));
		System.assertEquals(testEvent.Id, DC_EventDAO.getEventById(testEvent.Id).Id);
	}
	
	@IsTest
	private static void test_SoqlUtils_performQuery()
	{
		//INCORRECT DATA
		DC_SoqlQueryBuilder queryBuilder = null;
		System.assertEquals(null, DC_SoqlUtils.performQuery(queryBuilder));
		System.assertEquals(null, DC_SoqlUtils.performQuery(''));
		System.assertEquals(null, DC_SoqlUtils.performQuery('Select UnknownField From UnknownObject'));
		
		//CORRECT DATA
		queryBuilder = new DC_SoqlQueryBuilder('Id', 'User');
		queryBuilder.condition = 'Id = \'' + UserInfo.getUserId() + '\'';
		User[] users = DC_SoqlUtils.performQuery(queryBuilder);
		System.assertEquals(1, users.size());
		System.assertEquals(UserInfo.getUserId(), users[0].Id);
	}
	
	@IsTest
	private static void test_SoqlUtils_performSingleResultQuery()
	{
		//INCORRECT DATA
		DC_SoqlQueryBuilder queryBuilder = null;
		System.assertEquals(null, DC_SoqlUtils.performSingleResultQuery(queryBuilder));
		System.assertEquals(null, DC_SoqlUtils.performSingleResultQuery(''));
		
		//CORRECT DATA
		queryBuilder = new DC_SoqlQueryBuilder('Id', 'User');
		queryBuilder.condition = 'Id = \'' + UserInfo.getUserId() + '\'';
		User user = (User)DC_SoqlUtils.performSingleResultQuery(queryBuilder);
		System.assertEquals(UserInfo.getUserId(), user.Id);
	}
	
	@IsTest
	private static void test_SoqlUtils_createQueryLocator()
	{
		//wrong parameters
		System.assertEquals(null, DC_SoqlUtils.createQueryLocator(null));
		System.assertEquals(null, DC_SoqlUtils.createQueryLocator(''));
		System.assertEquals(null, DC_SoqlUtils.createQueryLocator('Wrong query string'));
		
		//correct parameters
		System.assertNotEquals(null, DC_SoqlUtils.createQueryLocator(
			'Select Id From Account limit 10'));
	}
	//
	
	
	
	//
	//Test methods for 'DC_SoqlQueryBuilder' class
	//
	@IsTest
	private static void test_SoqlQueryBuilder_buildQuery()
	{
		//test #1
		DC_SoqlQueryBuilder builder = new DC_SoqlQueryBuilder('Id, Name', 'ObjectName');
		builder.condition = 'Id = 55555';
		System.assertEquals('SELECT Id, Name FROM ObjectName WHERE Id = 55555', builder.buildQuery());
		
		//test #2
		builder = new DC_SoqlQueryBuilder('Id, Name', 'ObjectName');
		builder.condition = 'Id = 55555';
		builder.setOrderByBlock(new DC_SortingField[] {
			new DC_SortingField('Name', DC_SoqlEnums.SortingOrder.Descending)});
		System.assertEquals('SELECT Id, Name FROM ObjectName WHERE Id = 55555 ORDER BY Name DESC NULLS FIRST', builder.buildQuery());
		
		//test #3
		builder = new DC_SoqlQueryBuilder('Name', 'ObjectName', 'Id = 55555');
		builder.setOrderByBlock(new DC_SortingField[] {new DC_SortingField('Name')});
		builder.limitOfResult = 100;
		builder.offsetOfResult = 10;
		builder.groupByBlockValue = 'Name';
		builder.havingBlockValue = 'Count(Id) > 1';
		System.assertEquals('SELECT Name FROM ObjectName WHERE Id = 55555 GROUP BY Name '
			+ 'HAVING Count(Id) > 1 ORDER BY Name ASC NULLS FIRST LIMIT 100 OFFSET 10', builder.buildQuery());
		
		//test #4
		builder = new DC_SoqlQueryBuilder('Name', 'ObjectName', 'Id = 55555');
		builder.groupByRollupBlockValue = 'Name';
		System.assertEquals('SELECT Name FROM ObjectName WHERE Id = 55555 GROUP BY ROLLUP (Name)',
			builder.buildQuery());
		
		//test #5
		builder = new DC_SoqlQueryBuilder('Id, Name', 'ObjectName');
		DC_SoqlEnums.SortingOrder nullSortingOrder = null;
		builder.setOrderByBlock(new DC_SortingField[] {
			new DC_SortingField('Field1', DC_SoqlEnums.SortingOrder.Ascending,
				DC_SoqlEnums.NullValuesSortingOrder.Last),
			new DC_SortingField('Field2', DC_SoqlEnums.SortingOrder.Descending),
			new DC_SortingField('', nullSortingOrder)});
		System.assertEquals('SELECT Id, Name FROM ObjectName ORDER BY Field1 ASC '
			+ 'NULLS LAST, Field2 DESC NULLS FIRST', builder.buildQuery());
		
		//test #6
		builder = new DC_SoqlQueryBuilder('Id, Name', 'ObjectName');
		builder.setOrderByBlock(null);
		System.assertEquals('SELECT Id, Name FROM ObjectName', builder.buildQuery());
		
		//test #7
		builder = new DC_SoqlQueryBuilder('', null);
		System.assertEquals(null, builder.buildQuery());
	}
	//
	
	
	
	//
	//Unit tests for 'DC_SortingField' class
	//
	@IsTest
	private static void test_SortingField_basicWork()
	{
		//- initialize the field
		DC_SortingField sortingField = new DC_SortingField('Field1');
		//- check all the parameters
		System.assertEquals('Field1', sortingField.name);
		System.assertEquals(DC_SoqlEnums.SortingOrder.Ascending,
			sortingField.sortingOrder);
		System.assertEquals(String.valueOf(DC_SoqlEnums.SortingOrder.Ascending),
			sortingField.getSortingOrderName());
		System.assertEquals(DC_SoqlEnums.NullValuesSortingOrder.First,
			sortingField.nullValuesOrder);
		
		//- reverse sorting order
		sortingField.reverseSortingOrder();
		System.assertEquals(DC_SoqlEnums.SortingOrder.Descending,
			sortingField.sortingOrder);
		
		//- reverse sorting order again
		sortingField.reverseSortingOrder();
		System.assertEquals(DC_SoqlEnums.SortingOrder.Ascending,
			sortingField.sortingOrder);
	}
	//
}