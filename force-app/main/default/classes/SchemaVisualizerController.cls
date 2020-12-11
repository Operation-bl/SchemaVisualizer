public with sharing class SchemaVisualizerController {

    private static final String NO_SOBJECT_ERROR_MESSAGE = 'There is no sObject with such API name in your database.';

    private static Map<String, Schema.SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }

    @AuraEnabled(cacheable=true)
    public static List<Option> getSObjectOptions() {

        List<Option> result = new List<Option>();

        for (String objectName : globalDescribe.keySet()) {
            result.add(
                new Option(
                    globalDescribe.get(objectName)
                )
            );
        }

        result.sort();

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static SObjectDescribeWrapper getWrappedSObjectDescribe(String sObjectApiName) {

        SObjectDescribeWrapper result;

        if (globalDescribe.containsKey(sObjectApiName)) {

            result = new SObjectDescribeWrapper(
                globalDescribe.get(sObjectApiName).getDescribe()
            );

        } else {
            throw new AuraHandledException(NO_SOBJECT_ERROR_MESSAGE);
        }

        return result;
    }

    @TestVisible
    class Option implements Comparable {

        @AuraEnabled public String label;
        @AuraEnabled public String value;

        Option(Schema.SObjectType typeInfo) {
            Schema.DescribeSObjectResult describeResult = typeInfo.getDescribe();
            this.label = describeResult.getLabel();
            this.value = describeResult.getName();
        }

        public Integer compareTo(Object objectToCompare) {
            Option optionToCompare = (Option)objectToCompare;
            return this.label.compareTo(optionToCompare.label);
        }
    }

    @TestVisible
    class SObjectDescribeWrapper {

        @AuraEnabled public String label;
        @AuraEnabled public String apiName;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public String keyPrefix;
        @AuraEnabled public Boolean isQueryable;
        @AuraEnabled public Boolean isUpdateable;
        @AuraEnabled public Boolean isAccessible;
        @AuraEnabled public List<FieldDescribeWrapper> fieldDescribes = new List<FieldDescribeWrapper>();

        SObjectDescribeWrapper(Schema.DescribeSObjectResult describeResult) {
            this.fillAttributes(describeResult);
        }

        private void fillAttributes(Schema.DescribeSObjectResult describeResult) {

            List<Schema.SObjectField> fields = describeResult.fields.getMap().values();

            this.label = describeResult.getLabel();
            this.apiName = describeResult.getName();
            this.isCustom = describeResult.isCustom();
            this.keyPrefix = describeResult.getKeyPrefix();
            this.isQueryable = describeResult.isQueryable();
            this.isUpdateable = describeResult.isUpdateable();
            this.isAccessible = describeResult.isAccessible();

            this.wrapFields(fields);

        }

        private void wrapFields(List<Schema.SObjectField> fields) {

            for (Schema.SObjectField field : fields) {
                this.fieldDescribes.add(
                    new FieldDescribeWrapper(field.getDescribe())
                );
            }

            this.fieldDescribes.sort();
        }
    }

    @TestVisible
    class FieldDescribeWrapper implements Comparable {

        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean isCustom;
        @AuraEnabled public Boolean isReference;
        @AuraEnabled public Boolean isAccessible;

        FieldDescribeWrapper(Schema.DescribeFieldResult fieldDescribe) {
            this.fillAttributes(fieldDescribe);
        }

        public Integer compareTo(Object objectToCompare) {
            FieldDescribeWrapper fieldDescribeWrapperToCompare = (FieldDescribeWrapper) objectToCompare;
            return this.label.compareTo(fieldDescribeWrapperToCompare.label);
        }

        private void fillAttributes(Schema.DescribeFieldResult fieldDescribe) {

            this.name = fieldDescribe.getName();
            this.label = fieldDescribe.getLabel();
            this.isCustom = fieldDescribe.isCustom();
            this.isReference = String.isNotBlank(fieldDescribe.getRelationshipName());
            this.isAccessible = fieldDescribe.isAccessible();

        }
    }
}