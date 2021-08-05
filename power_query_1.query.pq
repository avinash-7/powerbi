let
    
    Source = Csv.Document(File.Contents("E:\mindstix\power bi\power query\titanic.csv"),[Delimiter=",", Columns=14, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    
    // Promoting headers means using first row as header
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    
    //changing the data type of the columns
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"pclass", Int64.Type}, {"survived", type text}, {"name", type text}, {"sex", type text}, {"age", type number}, {"sibsp", Int64.Type}, {"parch", Int64.Type}, {"ticket", type text}, {"fare", type number}, {"cabin", type text}, {"embarked", type text}, {"boat", type text}, {"body", Int64.Type}, {"home.dest", type text}}),
    
    //removing tehe column pclas
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"pclass"}),
    #"Reordered Columns" = Table.ReorderColumns(#"Removed Columns",{"name", "sex", "age", "survived", "sibsp", "parch", "ticket", "fare", "cabin", "embarked", "boat", "body", "home.dest"}),
    
    // Renaming the column
    #"Renamed Columns" = Table.RenameColumns(#"Reordered Columns",{{"name", "Name"}}),

    //Filtering 
    #"Filternull" = Table.SelectRows(#"Renamed Columns", each [age] <> "null"),
    #"ChangeTypes" = Table.TransformColumnTypes(#"Filternull", {{"age", Number.Type}}),
    #"Filterkids" = Table.SelectRows(#"ChangeTypes",each [age] > 5),

    //replacing the values accordingly
    #"Replace0 survived" = Table.ReplaceValue(#"Filterkids","0","No",Replacer.ReplaceText,{"survived"}),
    #"Replace1 survived" = Table.ReplaceValue(#"Replace0 survived","1","Yes",Replacer.ReplaceText,{"survived"}),

    //changing the case
    #"Change Case" = Table.TransformColumns(#"Replace1 survived",{"sex",Text.Proper}),

    //add calculated column based on averages ages
    
    //first of all lets calculte average age of females
    #"Female" = Table.SelectRows(#"Change Case",each [sex]="Female"),
    #"Avg Female" = List.Average(Table.Column(#"Female","age")), //valus returned will be scalar

    //calculate average for males
    #"Male" = Table.SelectRows(#"Change Case",each [sex]="Male"),
    #"Avg Male" = List.Average(Table.Column(#"Male","age")),

    //chcking if value is female then replacing by diff and same for male
    #"adcol" = Table.AddColumn(#"Change Case","agediff",each if [sex]="Female" then [age]-#"Avg Female" else [age]- #"Avg Male"),
    #"RoundDiff" = Table.TransformColumns(#"adcol", {"agediff", each Number.Round(_,2)})

    
in
    #"RoundDiff"
