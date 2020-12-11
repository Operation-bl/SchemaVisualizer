@isTest
private class SchemaVisualizerControllerTest {

    @isTest
    private static void testSelections() {

        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        Test.startTest();
        List<SchemaVisualizerController.Option> actualResults = SchemaVisualizerController.getSObjectOptions();
        Test.stopTest();

        System.assertEquals(globalDescribe.size(), actualResults.size());

        for (SchemaVisualizerController.Option option : actualResults) {
            System.assert(globalDescribe.containsKey(option.value), 'Invalid Option value returned');
            System.assertEquals(globalDescribe.get(option.value).getDescribe().getLabel(), option.label);
        }

    }

    @isTest
    private static void testDescribe() {

        Schema.DescribeSObjectResult expectedDescribe = Account.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> expectedFields = expectedDescribe.fields.getMap();

        Test.startTest();
        SchemaVisualizerController.SObjectDescribeWrapper actualResult = SchemaVisualizerController.getWrappedSObjectDescribe('account');
        Test.stopTest();

        System.assertEquals(expectedDescribe.getLabel(), actualResult.label);
        System.assertEquals(expectedDescribe.getName(), actualResult.apiName);
        System.assertEquals(expectedDescribe.isCustom(), actualResult.isCustom);
        System.assertEquals(expectedDescribe.getKeyPrefix(), actualResult.keyPrefix);
        System.assertEquals(expectedDescribe.isQueryable(), actualResult.isQueryable);
        System.assertEquals(expectedDescribe.isUpdateable(), actualResult.isUpdateable);
        System.assertEquals(expectedDescribe.isAccessible(), actualResult.isAccessible);
        System.assertEquals(expectedFields.size(), actualResult.fieldDescribes.size());

        for (SchemaVisualizerController.FieldDescribeWrapper actualField : actualResult.fieldDescribes) {
            System.assert(expectedFields.containsKey(actualField.name));
            System.assertEquals(expectedFields.get(actualField.name).getDescribe().getName(), actualField.name);
            System.assertEquals(expectedFields.get(actualField.name).getDescribe().getLabel(), actualField.label);
            System.assertEquals(expectedFields.get(actualField.name).getDescribe().isCustom(), actualField.isCustom);
            System.assertEquals(expectedFields.get(actualField.name).getDescribe().isAccessible(), actualField.isAccessible);
            System.assertEquals(
                String.isNotBlank(
                    expectedFields.get(actualField.name).getDescribe().getRelationshipName()
                ),
                actualField.isReference
            );
        }
    }

    @isTest
    private static void negativeTestDescribe() {
        Boolean wasExceptionThrown = false;
        try {
            Test.startTest();
            SchemaVisualizerController.SObjectDescribeWrapper actualResult =
                SchemaVisualizerController.getWrappedSObjectDescribe('YOU WILL NEWER HAVE SUCH AN SOBJECT API NAME');
            Test.stopTest();
        } catch(AuraHandledException e) {
            // Still have no possibility to check is there correct or incorrect message in the AuraHandledException
            wasExceptionThrown = true;
            System.assert(true);
        } catch(Exception e) {
            wasExceptionThrown = true;
            System.assert(false, 'Unhandled exception was thrown');
        }
        System.assert(wasExceptionThrown, 'No exception was thrown');
    }
}
