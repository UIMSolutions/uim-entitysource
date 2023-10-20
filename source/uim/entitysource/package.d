module uim.entitysource;

@safe:
public import uim.core;
public import uim.oop;

// public import colored;
public import vibe.d;

public import uim.entities;

public import uim.entitysource.file;
public import uim.entitysource.helpers;
public import uim.entitysource.cache;
public import uim.entitysource.source;
public import uim.entitysource.memory;
public import uim.entitysource.mongo;
public import uim.entitysource.tests;


string filePath(Json json, string sep = "/", string extension = ".json") {
  if (json.isEmpty) return "";
 
  if ("id" in json && "versionNumber" in json) return json["id"].get!string~sep~"1"~extension;

  return ("id" in json) ? 
    json["id"].get!string~sep~to!string(json["versionNumber"].get!size_t)~".json" : "";
}

/* string jsonFilePath(Json json, string sep = "/") {
  if (json.isEmpty) return "";
 
  if ("id" in json && "versionNumber" in json) return json["id"].get!string~sep~"1.json";

  return ("id" in json) ? 
    json["id"].get!string~sep~to!string(json["versionNumber"].get!size_t)~".json" : "";
} */

/* string jsonFilePath(string startPath, Json json, string sep = "/") {
  if (json.isEmpty) return "";
  return startPath~sep~jsonFilePath(json, sep);
} */

// #region check
  bool checkVersion(_VERSION value, string[] keys = null) {
    if (value.isEmpty) { return false; }

    foreach (key; keys) if (key !in value) { return false; }
    return true;
  }

  bool checkVersion(_VERSION value, UUID id, size_t vNumber = 0) {
    if (!checkVersion(value, ["id", "versionNumber"])) { return false; } // Testing against null results in false

    if (vNumber == 0) return (value["id"].get!string == id.toString);
    return (value["id"].get!string == id.toString) && (value["versionNumber"].get!size_t == vNumber);
  }

  bool checkVersion(_VERSION value, STRINGAA selector) {
    debug writeln("bool checkVersion(_VERSION value, STRINGAA selector)");
    if (!checkVersion(value)) { return false; } // Testing against null results in false
    if (selector.empty) { return false; } // Testing against null results in false

    foreach (key; selector.byKey) {      
      debug writeln("-> "~key~"/"~selector[key]);
      if (key !in value) { return false; }
      debug writeln("-> %s : %s".format(value[key].type, value[key]));
      switch (value[key].type) {
        case Json.Type.string:
          if (value[key].get!string != selector[key]) { return false; }
          break;
        default:
          if (value[key].toString != selector[key]) { return false; }
          break;
      }
    }
    return true;
  }
  unittest {
    auto json = parseJsonString(`{"a":"b", "c":{"d":1}, "e":["f", {"g":"h"}], "i":1}`);
    assert(checkVersion(json, ["a":"b"]), "Wrong CheckVersion result. Should be true -> %s for %s using %s".format(checkVersion(json, ["a":"b"]), json, ["a":"b"]));

/*     auto selector = ["a":"b"];
    foreach (key; selector.byKey) {  
      writeln("key -> ", key);    
      if (key !in json) writeln("(key !in json)"); else writeln("(key in json)");
      switch (json[key].type) {
        case Json.Type.string:
          if (json[key].get!string != selector[key]) writeln("(json[key].get!string != selector[key])"); else writeln("(json[key].get!string == selector[key])");
          break;
        default:
          if (json[key].toString != selector[key]) writeln("(json[key].toString != selector[key])"); else writeln("(json[key].toString == selector[key])");
          break;
      }
    } */

    assert(checkVersion(json, ["a":"b", "i":"1"]));
    assert(!checkVersion(json, ["a":"y"]));
    assert(!checkVersion(json, ["x":"y"]));
  }

  bool checkVersion(_VERSION ver, Json selector) {
    if (ver.isEmpty) { return false; } // Testing against null results in false
    if (selector.isEmpty) { return false; } // Testing against null results in false

    foreach (kv; selector.byKeyValue) 
      if (kv.key !in ver || ver[kv.key] != selector[kv.key]) { return false; }
    return true;
  }
  unittest {
    auto json = parseJsonString(`{"a":"b", "c":{"d":1}, "e":["f", {"g":"h"}], "i":1}`);
    assert(checkVersion(json, parseJsonString(`{"a":"b"}`)));
    assert(checkVersion(json, parseJsonString(`{"a":"b", "c":{"d":1}}`)));
    assert(!checkVersion(json, parseJsonString(`{"a":"y"}`)));
    assert(!checkVersion(json, parseJsonString(`{"x":"y"}`)));
  }

  bool checkVersion(T)(_VERSION entity, string key, T value) {
    return (key in entity) && (entity[key].get!T == value);
  }
// #endregion check

Json toJson(UUID id, size_t versionNumber = 0) {
  auto result = Json.emptyObject;

  result["id"] = id.toString;
  result["versionNumber"] = versionNumber > 0 ? versionNumber : 1;

  return result; 
}

/* Json toJson(STRINGAA values) {
  auto result = Json.emptyObject;

  if ("id" in values) result["id"] = values["id"];
  result["versionNumber"] = "versionNumber" in values ? to!size_t(values["versionNumber"]) : 1;

  return result; 
} */

string dirPath(string path, UUID id, string separator = "/") {
  return path~dirPath(id, separator);
}
string dirPath(UUID id, string separator = "/") {
  return separator~id.toString;
}

string dirPath(string path, Json json, string separator = "/") {
  if (json.isEmpty) return "";
  if ("id" !in json) return "";

  return path~dirPath(json, separator);
}
string dirPath(Json json, string separator = "/") {
  if (json.isEmpty) return "";
  if ("id" !in json) return "";

  return separator~json["id"].get!string;
}

string filePath(string path, UUID id, size_t versionNumber, string separator = "/") {
  return path~filePath(id, versionNumber, separator);
}
string filePath(UUID id, size_t versionNumber, string separator = "/") {
  return dirPath(id, separator)~separator~toString(versionNumber > 0 ? versionNumber : 1)~".json";
}
string filePath(string path, Json json, string separator = "/") {
  if (json.isEmpty) return "";
  if ("id" !in json) return "";

  return path~filePath(json, separator);
}
string filePath(Json json, string separator = "/") {
  if (json.isEmpty) return "";
  if ("id" !in json) return "";

  return dirPath(json, separator)~separator~("versionNumber" in json ? 
    to!string(json["versionNumber"].get!long > 0 ? json["versionNumber"].get!long : 1) : "1")~".json";
}