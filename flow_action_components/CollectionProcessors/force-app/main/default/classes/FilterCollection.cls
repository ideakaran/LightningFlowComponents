public with sharing class FilterCollection {
    @InvocableMethod
    public static List <Results> filter(List<Requests> requestList) {

        String formulaString = requestList[0].formula;
        List<SObject> inputCollection = requestList[0].inputCollection;
        List<SObject> outputCollection = new List<SObject>();

        //for each member of the inputCollection, call the FormulaEvaluator.parseFormua method, which
        //will return true if the formula is true for this member
        //the FormulaEvaluator will use the recordId of the current member as context, replacing expressions in the 
        //formula string of the form $Record.fieldname. For example, if the formula is '$Record.Age__c > 21' and the input Collection
        //is a collection of Student__c, the evaluator will take the current student's ID, retrieve the record, and look for a field 'Student__c.Age__c' 
        //This package includes an expressionBuilder flow screen component that can be added to flows that are used to generate formula strings. These strings are
        //usually generated in a separate 'management' flow from the runtime flow that does this filtering.
        if (inputCollection != null && !inputCollection.isEmpty()) {
            for (SObject member : inputCollection) {
                List<FormulaEvaluator.ContextWrapper> context = new List<FormulaEvaluator.ContextWrapper>();
                context.add(new FormulaEvaluator.ContextWrapper('$Record', member.Id));
                String stringContext = JSON.serialize(context);
                String result = FormulaEvaluator.parseFormula(formulaString, stringContext);
                if (result == 'true') {
                    outputCollection.add(member);
                }
            }
        }

        Results response = new Results();
        response.outputCollection = outputCollection;
        List<Results> responseWrapper = new List<Results>();
        responseWrapper.add(response);

        return responseWrapper;

    }

    public class Requests {
        @InvocableVariable(required=true)
        public List<SObject> inputCollection;

        @InvocableVariable
        public String formula;

    }

    public class Results {

        public Results() {
            outputCollection = new List<SObject>();
        }

        @InvocableVariable
        public String errors;

        @InvocableVariable
        public List<SObject> outputCollection;
    }
}