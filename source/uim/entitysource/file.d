module uim.entitysource.file;

@safe:
import uim.entitysource;

class DEDBFileSource : DESCEntitySource {
  this() { super(); this.separator("/"); }
  this(string newPath) { this().path(newPath); }
  
  mixin(SProperty!("string", "path"));

  // #region read
  // Searching in store
  alias findMany = DESCEntitySource.findMany;
  override Json[] findMany(string collection, bool allVersions = false) {
    debug writeln("In findMany(", collection, ",", allVersions, ")");

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("-> Missing collection: ", pathToCollection);
      return null; }

    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions); }
    return results; }
  unittest {}

  override Json[] findMany(string collection, UUID id, bool allVersions = false) {
    debug writeln("In findMany(collection,id,allVersions)");

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("In findMany: Missing collection: ", pathToCollection);
      return null; }
   
    auto pathToId = dirPath(pathToCollection, id);
    if (!pathToId.exists) {
      debug writeln("In findMany: Missing if: ", pathToId);
      return null; }

    auto versions = loadJsonsFromDirectory(pathToId);
    if (versions.length > 0) return versions;
    auto lastVersion = uim.entities.repositories.lastVersion(versions);
    return lastVersion != Json(null) ? [lastVersion] : null; }
  unittest {}

  override Json[] findMany(string collection, STRINGAA select, bool allVersions = false) {
    debug writeln("In findMany(string collection, STRINGAA select, bool allVersions = false)");
    debug writeln("-> findMany(", collection, ",", select, ",", allVersions, ")");

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("-> Missing collection: ", pathToCollection);
      return null; }

    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions);
    }
    debug writeln("-> Found entries: ", results.length);
    return results.filter!(a => checkVersion(a, select)).array; }

  override Json[] findMany(string collection, Json select, bool allVersions = false) {
    debug writeln("In findMany(", collection, ",", allVersions, ")");

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("-> Missing collection: ", pathToCollection);
      return null; }

    auto entityIds = dirNames(pathToCollection, true);    
    Json[] results;
    foreach(pathToId; entityIds) {
      auto allEntityVersions = loadJsonsFromDirectory(pathToId);
      if (allVersions) results ~= allEntityVersions;
      else results ~= uim.entities.repositories.lastVersion(allEntityVersions); }

    return results.filter!(a => checkVersion(a, select)).array; }

  alias findOne = DESCEntitySource.findOne;
  override Json findOne(string collection, UUID id, bool allVersions = false) {
    debug writeln("In findOne(", collection, ",", id, ",", allVersions, ")");
    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("In findMany: Missing collection: ", pathToCollection);
      return Json(null); }

    auto pathToId = dirPath(pathToCollection, id, separator);
    if (!pathToId.exists) {
      debug writeln("In findMany: Missing id: ", pathToId);
      return Json(null); }

    auto allEntityVersions = loadJsonsFromDirectory(pathToId);
    if (allEntityVersions.empty) return Json(null); 
    
    if (allVersions) return allEntityVersions[0];
    else return uim.entities.repositories.lastVersion(allEntityVersions); }
  unittest {
/*     auto ds = EDBFileSource("./tests");
    assert(test_findOne_id(ds));
    assert(test_findOne_id_allVersions(ds));
 */  }    

  override Json findOne(string collection, UUID id, size_t versionNumber) {
    debug writeln("DEDBFileSource:findOne(", collection, ",", id, ",", versionNumber, ")");

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("In findMany: Missing collection: ", pathToCollection);
      return Json(null); }

    auto pathToId = dirPath(pathToCollection, id, separator);
    if (!pathToId.exists) {
      debug writeln("In findMany: Missing id: ", pathToId);
      return Json(null); }

    auto pathToVersion = filePath(pathToCollection, toJson(id, versionNumber), separator);
    if (!pathToVersion.exists) {
      debug writeln("In findMany: Missing version: ", pathToVersion);
      return Json(null); }

    return loadJson(pathToVersion); }
  unittest {
/*     auto ds = EDBFileSource("./tests");
    assert(test_findOne_id_versionNumber(ds)); */
  }    

  override Json findOne(string collection, STRINGAA select, bool allVersions = false) {
    debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("-> Missing collection: ", pathToCollection);
      return Json(null); }
    
    if ("id" in select && "versionNumber" !in select) return findOne(collection, UUID(select["id"]), allVersions);
    if ("id" in select && "versionNumber" in select) return findOne(collection, UUID(select["id"]), to!size_t(select["versionNumber"]));

    auto jsons = findMany(collection, select, allVersions);
    debug writeln("-> Found jsons: ", jsons.length);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
/*     auto ds = EDBFileSource("./tests");
    auto select = [
      "id": "0a9f35a0-be1f-4f3f-9d03-97bfba36774d", 
      "versionNumber": "1"];
    auto json = ds.findOne("entities", select);
    assert(json != Json(null), "json not found"); */
  }    

  override Json findOne(string collection, Json select, bool allVersions = false) {
    debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      debug writeln("In findMany: Missing collection: ", pathToCollection);
      return Json(null); }

    if ("id" in select && "versionNumber" !in select) return findOne(collection, UUID(select["id"].get!string), allVersions);
    if ("id" in select && "versionNumber" in select) return findOne(collection, UUID(select["id"].get!string), select["versionNumber"].get!size_t);

    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
    // debug writeln((StyledString("Test Json findOne(string collection, Json select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));
/*     auto ds = EDBFileSource("./tests");
    auto json = Json.emptyObject;
    json["id"] = "0a9f35a0-be1f-4f3f-9d03-97bfba36774d";
    json["versionNumber"] = 1;
    json = ds.findOne("entities", json);
    assert(json != Json(null)); */
  }    
  // #endregion

// #region create
  alias insertOne = DESCEntitySource.insertOne;
  override Json insertOne(string collection, Json newData) {
    if (newData == Json(null)) {
      debug writeln("No data");
      return Json(null);
    }

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) {
      // debug writeln("In insertOne: Missing path: ",pathToCollection);
      pathToCollection.mkdir;
    }

    if ("id" !in newData) newData["id"] = randomUUID.toString;
    auto pathToId = dirPath(pathToCollection, newData);
    if (!pathToId.exists) {
      debug writeln("In insertOne: Missing id: ", pathToId);
      pathToId.mkdir;
    }

    if ("versionNumber" !in newData) newData["versionNumber"] = 1;
    auto pathToVersion = filePath(pathToCollection, newData);

    auto nw = now();
    if ("createdOn" !in newData) newData["createdOn"] = toTimestamp(nw);
    if ("versionOn" !in newData) newData["versionOn"] = toTimestamp(nw);
    if ("modifiedOn" !in newData) newData["modifiedOn"] = toTimestamp(nw);

    std.file.write(pathToVersion, newData.toString);
    return findOne(collection, newData);
  }  
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto ds = EDBFileSource("./tests");
    const json = ds.insertOne("entities", OOPEntity.toJson);
    assert(json != Json(null));
  }
// #endregion create

// #region UpdateMany
  alias updateMany = DESCEntitySource.updateMany;
  override size_t updateMany(string collection, Json select, Json updateData) {
    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return 0;

    auto jsons = findMany(collection, select); 
    foreach(json; jsons) {
      foreach(kv; updateData.byKeyValue) {
        if (kv.key == "id") continue;
        if (kv.key == "versionNumber") continue;

        json[kv.key] = kv.value; }
      std.file.write(filePath(pathToCollection, json, separator), json.toString);
    }
    return jsons.length;
  }

  alias updateOne = DESCEntitySource.updateOne;
  override bool updateOne(string collection, Json select, Json updateData) {
    debug writeln("DEDBFileSource:updateOne(string collection, Json select, Json updateData)");
    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return false;

    auto json = findOne(collection, select);
    if (json == Json(null)) return false;

    foreach(kv; updateData.byKeyValue) json[kv.key] = kv.value;  
    std.file.write(filePath(pathToCollection, json, separator), json.toString);
    return true; }
// #endregion update

// #region removeMany by entity  
  alias removeMany = DESCEntitySource.removeMany;
  override size_t removeMany(string collection, UUID id, bool allVersions = false) {
    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return 0;

    size_t counter;
    foreach(json; findMany(collection, id, allVersions)) counter += removeOne(collection, json, allVersions);
    return counter; }

  override size_t removeMany(string collection, UUID id, size_t versionNumber) {
    // debug writeln(StyledString("DEDBFileSource:removeMany(collection, id, versionNumber)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return 0;

    auto pathToId = dirPath(pathToCollection, id, separator);
    if (!pathToId.exists) return 0;

    auto pathToVersion = filePath(pathToCollection, toJson(id, versionNumber), separator);
    if (!pathToVersion.exists) return 0;

    pathToVersion.remove;
    if (fileNames(pathToId, true).empty) pathToId.remove;
    return (!pathToVersion.exists ? 1 : 0); } 

  override size_t removeMany(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln(StyledString("DEDBFileSource:removeMany(collection, select, allVersions)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return 0;

    size_t counter;
    foreach(json; findMany(collection, select, allVersions)) counter += removeOne(collection, json, allVersions);
    return counter; }

  override size_t removeMany(string collection, Json select, bool allVersions = false) {
    // debug writeln(StyledString("DEDBFileSource:removeMany(collection, jselect, allVersions)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return 0;

    size_t counter;
    foreach(json; findMany(collection, select, allVersions)) counter += removeOne(collection, json, allVersions);
    return counter; }
// #endregion DeleteMany

// #region removeOne  
  alias removeOne = DESCEntitySource.removeOne;
  override bool removeOne(string collection, UUID id, bool allVersions = false) {
    // debug writeln(StyledString("DEDBFileSource:removeOne(collection, id, allVersions)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return false;

    auto json = findOne(collection, id, allVersions); 
    if (json != Json(null)) {
      auto jPath = filePath(pathToCollection, json, separator);
      debug writeln("Remove ", jPath);
      jPath.remove;
      return !jPath.exists; }

    return false; } 
  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, UUID id, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto ds = EDBFileSource("./tests");
    auto entity = OOPEntity;
    auto json = ds.insertOne("entities", entity);
    assert(ds.removeOne("entities", json));    

    entity = OOPEntity;
    json = ds.insertOne("entities", entity);
    assert(ds.removeOne("entities", json));    
  }

  override bool removeOne(string collection, UUID id, size_t versionNumber) {
    // debug writeln(StyledString("DEDBFileSource:removeOne(collection, id, versionNumber)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return false;

    auto pathToId = dirPath(pathToCollection, id, separator);
    if (!pathToId.exists) return false;

    auto pathToVersion = filePath(pathToCollection, id, versionNumber, separator);
    if (!pathToId.exists) return false;

    pathToVersion.remove;
    if (fileNames(pathToId, true).empty) pathToId.remove;
    return (!pathToVersion.exists ? true : false); } 
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto ds = EDBFileSource("./tests");
    auto entity = OOPEntity;
    auto json = ds.insertOne("entities", entity);
    assert(ds.removeOne("entities", json));    
  }

  override bool removeOne(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln(StyledString("DEDBFileSource:removeOne(collection, select, allVersions)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return false;

    if ("id" in select) {
      auto id = UUID(select["id"]);
      auto pathToId = dirPath(pathToCollection, id, separator);
      if (!pathToId.exists) return false;

      if ("versionNumber" in select) {
        auto versionNumber = to!size_t(select["versionNumber"]);
        auto pathToVersion = filePath(pathToCollection, id, versionNumber, separator);
        if (!pathToId.exists) return false;

        pathToVersion.remove;
        if (fileNames(pathToId, true).empty) pathToId.remove;
        return (!pathToVersion.exists ? true : false); 
      }
    }
    auto json = findOne(collection, select, allVersions); 
    if (json != Json(null)) return removeOne(collection, json, false);
    return false; }
  unittest {
    auto ds = EDBFileSource("./tests");
    assert(test_removeOne_collection_select(ds));    
    assert(test_removeOne_collection_select_allVersions(ds));
  }

  override bool removeOne(string collection, Json select, bool allVersions = false) {
    // debug writeln(StyledString("DEDBFileSource:removeOne(collection, select, allVersions)").setForeground(AnsiColor.black).setBackground(AnsiColor.white));

    auto pathToCollection = path~separator~collection;
    if (!pathToCollection.exists) return false;

    if ("id" in select) {
      auto id = UUID(select["id"].get!string);
      auto pathToId = dirPath(pathToCollection, id, separator);
      if (!pathToId.exists) return false;

      if ("versionNumber" in select) {
        auto versionNumber = select["versionNumber"].get!size_t;
        auto pathToVersion = filePath(pathToCollection, id, versionNumber, separator);
        if (!pathToVersion.exists) return false;

        pathToVersion.remove;
        if (fileNames(pathToId, true).empty) pathToId.remove;
        return (!pathToVersion.exists ? true : false);  
      }
    }
 
    auto json = findOne(collection, select, allVersions); 
    if (json != Json(null)) return removeOne(collection, json, false); 
    return false; }

  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, Json select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto ds = EDBFileSource("./tests");
    assert(test_removeOne_collection_jsonselect(ds));    
    assert(test_removeOne_collection_jsonselect_allVersions(ds));
  }
// #endregion removeOne
}
auto EDBFileSource() { return new DEDBFileSource; }
auto EDBFileSource(string path) { return EDBFileSource.path(path); }