module uim.entitysource;

@safe:
public import uim.core;
public import uim.oop;

public import colored;
public import vibe.d;

public import uim.entitysource.file;
public import uim.entitysource.helpers;
public import uim.entitysource.cache;
public import uim.entitysource.entitysource;
public import uim.entitysource.memory;
public import uim.entitysource.mongo;
public import uim.entitysource.tests;

string jsonFilePath(Json json, string sep = "/") {
  if (json == Json(null)) return "";

  // debug writeln("2 Path: ",json["id"].get!string~sep~to!string(json["versionNumber"].get!size_t));
  return ("id" in json) && ("versionNumber" in json) ? 
    json["id"].get!string~sep~to!string(json["versionNumber"].get!size_t) : "";
}

string jsonFilePath(string startPath, Json json, string sep = "/") {
  if (auto jPath = jsonFilePath(json, sep)) {
    // debug writeln("2 Path: ", startPath~sep~jPath);
    return startPath~sep~jPath;
  }
  return "";
}

// #region check
  bool checkVersion(_VERSION value, string[] keys = null) {
    if (value == Json(null)) return false;

    foreach (key; keys) if (key !in value) return false;
    return true;
  }

  bool checkVersion(_VERSION value, UUID id, size_t vNumber = 0) {
    if (!checkVersion(value, ["id", "versionNumber"])) return false; // Testing against null results in false

    if (vNumber == 0) return (value["id"].get!string == id.toString);
    return (value["id"].get!string == id.toString) && (value["versionNumber"].get!size_t == vNumber);
  }

  bool checkVersion(_VERSION value, STRINGAA selector) {
    if (!checkVersion(value)) return false; // Testing against null results in false
    if (selector.empty) return false; // Testing against null results in false

    foreach (key; selector.byKey) {      
      if (key !in value) return false;
      switch (value[key].type) {
        case Json.Type.string:
          if (value[key].get!string != selector[key]) return false;
          break;
        default:
          if (value[key].toString != selector[key]) return false;
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
    if (ver == Json(null)) return false; // Testing against null results in false
    if (selector == Json(null)) return false; // Testing against null results in false

    foreach (kv; selector.byKeyValue) 
      if (kv.key !in ver || ver[kv.key] != selector[kv.key]) return false;
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
