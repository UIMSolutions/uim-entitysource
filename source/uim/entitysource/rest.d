module source.uim.entitysource.rest;

@safe:
import uim.entitysource;

class DEDBRestentitysource : DESCEntitySource {
  this() { super(); this.separator("/"); }
  this(string newPath) { this().path(newPath); }
  
  mixin(SProperty!("string", "path"));

  // #region read
  // Searching in store
  alias findMany = DESCEntitySource.findMany;
  override Json[] findMany(string collection, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");

    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) {
      // debug writeln("In findMany: Missing path: ",pathToCollection);
      return null;
    }

    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions);
    }
    return results; }
  unittest {}

  override Json[] findMany(string collection, UUID id, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", id, ",", allVersions, ")");

    auto pathToId = path~"/"~collection~"/"~id.toString;
    if (!pathToId.exists) {
      // debug writeln("In findMany: Missing id: ", pathToId);
      return null;
    }

    auto versions = loadJsonsFromDirectory(pathToId);
    if (versions.length > 0) return versions;
    auto lastVersion = uim.entities.repositories.lastVersion(versions);
    return lastVersion != Json(null) ? [lastVersion] : null; }
  unittest {}

  override Json[] findMany(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");

    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) {
      // debug writeln("In findMany: Missing path: ",pathToCollection);
      return null;
    }

    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions);
    }
    return results.filter!(a => checkVersion(a, select)).array; }

  override Json[] findMany(string collection, Json select, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");

    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) {
      // debug writeln("In findMany: Missing path: ",pathToCollection);
      return null;
    }

    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions); }

    return results.filter!(a => checkVersion(a, select)).array; }

  alias findOne = DESCEntitySource.findOne;
  override Json findOne(string collection, UUID id, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", id, ",", allVersions, ")");
    auto jsons = findMany(collection, id, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
/*     auto rep = EDBRestentitysource("./tests");
    auto json = rep.findOne("entities", UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d"));
    assert(json != Json(null), "Json not found");
 */  }    

  override Json findOne(string collection, UUID id, size_t versionNumber) {
    // debug writeln("In findOne(", collection, ",", id, ",", versionNumber, ")");
    return Json(null); }
  unittest {/* 
    auto rep = EDBRestentitysource("./tests");
    auto json = rep.findOne("entities", UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d"), 1);
    assert(json != Json(null));
 */  }    

  override Json findOne(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
/*     auto rep = EDBRestentitysource("./tests");
    auto select = [
      "id": "0a9f35a0-be1f-4f3f-9d03-97bfba36774d", 
      "versionNumber": "1"];
    auto json = rep.findOne("entities", select);
    assert(json != Json(null), "json not found"); */
  }    

  override Json findOne(string collection, Json select, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
/*     // debug writeln((StyledString("Test Json findOne(string collection, Json select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));
    auto rep = EDBRestentitysource("./tests");
    auto json = Json.emptyObject;
    json["id"] = "0a9f35a0-be1f-4f3f-9d03-97bfba36774d";
    json["versionNumber"] = 1;
    json = rep.findOne("entities", json);
    assert(json != Json(null)); */
  }    
  // #endregion

// #region create
  alias insertOne = DESCEntitySource.insertOne;
  override Json insertOne(string collection, Json newData) {
    if (newData == Json(null)) {
      // debug writeln("1: No data");
      return Json(null);
    }

    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) {
      // debug writeln("In insertOne: Missing path: ",pathToCollection);
      pathToCollection.mkdir;
    }

    auto json = OOPEntity.toJson;
    foreach(kv; newData.byKeyValue) json[kv.key] = kv.value;

    auto pathToId = pathToCollection~"/"~json["id"].get!string;
    if (!pathToId.exists) {
      // debug writeln("In insertOne: Missing id: ",pathToId);
      pathToId.mkdir;
    }

    // debug writeln("In CreateOne/path = ", filePath(pathToCollection, json));
    std.file.write(filePath(pathToCollection, json), json.toString);
    return findOne(collection, json);
  }  
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBRestentitysource("./tests");
    const json = rep.insertOne("entities", OOPEntity.toJson);
    assert(json != Json(null));
  }
// #endregion create

// #region UpdateMany
  alias updateMany = DESCEntitySource.updateMany;
  override size_t updateMany(string collection, Json select, Json updateData) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return 0;

    auto jsons = findMany(collection, select); 
    foreach(json; jsons) {
      foreach(kv; updateData.byKeyValue) {
        if (kv.key == "id") continue;
        if (kv.key == "versionNumber") continue;

        json[kv.key] = kv.value;
      }
      std.file.write(filePath(pathToCollection, json, separator), json.toString);
    }
    return jsons.length;
  }

  alias updateOne = DESCEntitySource.updateOne;
  override bool updateOne(string collection, Json select, Json updateData) {
    return false; }
// #endregion update

// #region removeMany by entity  
  alias removeMany = DESCEntitySource.removeMany;
  override size_t removeMany(string collection, UUID id, bool allVersions = false) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return 0;

    auto pathToId = pathToCollection~"/"~id.toString;
    if (!pathToId.exists) return 0;

    if (allVersions) {
      auto fNames = fileNames(pathToId, true);
      fNames.each!(a => a.remove);
      pathToId.remove; 
      return (!pathToId.exists ? fNames.length : 0); } 
    else {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      auto json = uim.entities.repositories.lastVersion(allEntityVersions);
      auto jsonPath = pathToId~"/"~json["versionNumber"].get!string;
      jsonPath.remove;
      return (!jsonPath.exists); } 
    }

  override size_t removeMany(string collection, UUID id, size_t versionNumber) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return 0;

    auto pathToId = pathToCollection~"/"~id.toString;
    if (!pathToId.exists) return 0;

    auto jsonPath = pathToId~"/"~to!string(versionNumber)~".json";
    if (jsonPath.exists) {
      jsonPath.remove;
      return (!jsonPath.exists ? 1 : 0); } 

    return 0; }

  override size_t removeMany(string collection, STRINGAA select, bool allVersions = false) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return 0;

    return 0; }

  override size_t removeMany(string collection, Json select, bool allVersions = false) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return 0;

    return 0; }
// #endregion DeleteMany

// #region removeOne  
  alias removeOne = DESCEntitySource.removeOne;
  override bool removeOne(string collection, UUID id, bool allVersions = false) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return false;

    auto json = findOne(collection, id, allVersions); 
    if (json != Json(null)) {
      auto jPath = filePath(pathToCollection, json);
      jPath.remove;
      return !jPath.exists; }

    return false; } 
  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, UUID id, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBRestentitysource("./tests");
    auto entity = OOPEntity;
    auto json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    

    entity = OOPEntity;
    json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    
  }

  override bool removeOne(string collection, UUID id, size_t versionNumber) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return false;

    auto json = findOne(collection, id, versionNumber); 
    if (json != Json(null)) {
      auto jPath = filePath(pathToCollection, json);
      jPath.remove;
      return !jPath.exists; }

    return false; }
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBRestentitysource("./tests");
    auto entity = OOPEntity;
    auto json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    
  }

  override bool removeOne(string collection, STRINGAA select, bool allVersions = false) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return false;
    
    auto json = findOne(collection, select, allVersions); 
    if (json != Json(null)) {
      auto jPath = filePath(pathToCollection, json);
      jPath.remove;
      return !jPath.exists; }

    return false; }
  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, STRINGAA select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBRestentitysource("./tests");
    assert(test_removeOne_collection_select(rep));    
    assert(test_removeOne_collection_select_allVersions(rep));
  }

  override bool removeOne(string collection, Json select, bool allVersions = false) {
    auto pathToCollection = path~"/"~collection;
    if (!pathToCollection.exists) return false;

    auto json = findOne(collection, select, allVersions); 
    if (json != Json(null)) {
      auto jPath = filePath(pathToCollection, json);
      jPath.remove;
      return !jPath.exists; }

    return false; }
  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, Json select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

/*     auto rep = EDBRestentitysource("./tests");
    assert(test_removeOne_collection_jsonselect(rep));    
    assert(test_removeOne_collection_jsonselect_allVersions(rep)); */
  }
// #endregion removeOne
}
auto EDBRestentitysource() { return new DEDBRestentitysource; }
auto EDBRestentitysource(string path) { return EDBRestentitysource.path(path); }