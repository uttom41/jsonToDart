import 'dart:io';

class JsonToDart{
  Map<String,dynamic> jsonData;
  JsonToDart({required this.jsonData});


  bool convert(){
    String lineBreak = '\n';
    String space = "  ";
    String tabSpace = "    ";
    String classProps = "";
    String constructor = "";
    String copyConstructor = "";
    String fromJson = "";
    String toJson = "";

    jsonData.forEach((key, value) {
      String tableName = key;
      String tableField;
      String fieldType;


      for(Map<String,dynamic> row in value){
        String nullValue="";
        bool privateAnnotation = false;
        tableField = _fieldNamePrepare(row["Field"]);
        fieldType = typeDefine(row["Type"]);
        String nullType = row["Null"];
        String key = row["Key"];
        if(nullType=="YES")nullValue="?";
        if(key == "PRI") privateAnnotation = true;

        //  classProps += "${privateAnnotation?"$tabSpace@Id();$lineBreak":""}$tabSpace$fieldType$nullValue$space$tableField;$lineBreak";
        classProps += "$tabSpace$fieldType$nullValue$space$tableField;$lineBreak";
        constructor += "$tabSpace${nullValue=="?"?"":"required$space"}this.$tableField,$lineBreak";

      }

      var myFile = File('bin/model/${tableName.toLowerCase()}.dart');

      String className = _capitalizeFirstLetter(tableName);
      //myFile.writeAsString("@Entity();$lineBreak class ${_capitalizeFirstLetter(tableName)} {$lineBreak $classProps $lineBreak}");
      myFile.writeAsString("class $className {$lineBreak$classProps$lineBreak$className({$lineBreak$constructor});$lineBreak}");

    });

    return true;
  }


  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    String finalOutput = "";
    bool underScore = false;
    finalOutput += input[0].toUpperCase();
    for(int i=1; i<input.length; i++){
      String char = input[i];
      if(char != "_") {
        finalOutput += underScore?char.toUpperCase():char.toLowerCase();
        underScore = false;
      }else {
        underScore = true;
      }
    }
    // String modInput = input.replaceAll("_","");
    //return modInput[0].toUpperCase() + modInput.substring(1);
    return finalOutput;
  }

  String _fieldNamePrepare(String input) {
    if (input.isEmpty) {
      return input;
    }
    String finalOutput = "";
    bool underScore = false;
    finalOutput += input[0].toLowerCase();
    for(int i=1; i<input.length; i++){
      String char = input[i];
      if(char != "_") {
        finalOutput += underScore?char.toUpperCase():char.toLowerCase();
        underScore = false;
      }else {
        underScore = true;
      }
    }
    // String modInput = input.replaceAll("_","");
    //return modInput[0].toUpperCase() + modInput.substring(1);
    return finalOutput;
  }

  String typeDefine (String type){
    return switch(_stringParse (type.toLowerCase())) {
    'int' => "int",
    'double' => 'double',
    'varchar' => 'String',
    'datetime' => 'String',
    'tinyint' => 'int',
    'longtext' => 'String',
    'date' => 'String',
    'decimal' => 'double',
    'smallint unsigned' => 'int',
    _ => "String",
  };
  }

  String _stringParse (String string) {
    final pattern = RegExp(r'^(.*)\(.*');
    var typeList = pattern.allMatches(string);
    if(typeList.isEmpty)return string;
    return typeList.elementAt(0).group(0)??string;
  }
}