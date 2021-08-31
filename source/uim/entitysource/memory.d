module uim.entitysource.memory;

@safe:
import uim.entitysource;

class DEDBMemoryentitysource : DESCEntitySource {
  this() { super(); }

  Json[size_t][UUID][string] _storage;

  // #region read
  // Searching in store
  alias findMany = DESCEntitySource.findMany;
  override Json[] findMany(string collection, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");
    
    auto entities = _storage.get("collection", null);
    if (entities.empty) return null;

    Json[] results;
    foreach(versions; entities.byValue) {
      if (allVersions) results ~= versions.byValue.array;
      else results ~= uim.oop.repositories.lastVersion(versions);
    }
    return results; }
  unittest {}

  override Json[] findMany(string collection, UUID id, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", id, ",", allVersions, ")");

    auto entities = _storage.get("collection", null);
    if (entities.empty) return null;

    auto versions = entities.get(id, null);
    if (versions.empty) return null;

  
    if (allVersions) return versions.byKeyValue.map!(a => a.value).array;
    auto lastVersion = uim.oop.repositories.lastVersion(versions);
    return lastVersion != Json(null) ? [lastVersion] : null; }
  unittest {}

  override Json[] findMany(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");
    return findMany(collection, allVersions).filter!(a => a.checkVersion(select)).array;
 }
 unittest {}

  override Json[] findMany(string collection, Json select, bool allVersions = false) {
    // debug writeln("In findMany(", collection, ",", allVersions, ")");

    return findMany(collection, allVersions).filter!(a => a.checkVersion(select)).array;
 }
 unittest {}

  alias findOne = DESCEntitySource.findOne;
  override Json findOne(string collection, UUID id, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", id, ",", allVersions, ")");
    auto jsons = findMany(collection, id, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
/*     auto rep = EDBFileSource("./tests");
    auto json = rep.findOne("entities", UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d"));
    assert(json != Json(null), "Json not found");
 */  }    

  override Json findOne(string collection, UUID id, size_t versionNumber) {
    // debug writeln("In findOne(", collection, ",", id, ",", versionNumber, ")");
    return Json(null); }
  unittest {
    auto rep = EDBFileSource("./tests");
    auto json = rep.findOne("entities", UUID("0a9f35a0-be1f-4f3f-9d03-97bfba36774d"), 1);
    assert(json != Json(null));
  }    

  override Json findOne(string collection, STRINGAA select, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
    auto rep = EDBFileSource("./tests");
    auto select = [
      "id": "0a9f35a0-be1f-4f3f-9d03-97bfba36774d", 
      "versionNumber": "1"];
    auto json = rep.findOne("entities", select);
    assert(json != Json(null), "json not found");
  }    

  override Json findOne(string collection, Json select, bool allVersions = false) {
    // debug writeln("In findOne(", collection, ",", select, ",", allVersions, ")");
    auto jsons = findMany(collection, select, allVersions);
    return jsons.length > 0 ? jsons[0] : Json(null); }
  unittest {
    // debug writeln((StyledString("Test Json findOne(string collection, Json select, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));
    auto rep = EDBFileSource("./tests");
    auto json = Json.emptyObject;
    json["id"] = "0a9f35a0-be1f-4f3f-9d03-97bfba36774d";
    json["versionNumber"] = 1;
    json = rep.findOne("entities", json);
    assert(json != Json(null));
  }    
  // #endregion

// #region create
  alias insertOne = DESCEntitySource.insertOne;
  override Json insertOne(string collection, Json newData) {
    if (newData == Json(null)) {
      // debug writeln("1: No data");
      return Json(null);
    }

    auto entities = _storage.get("collection", null);
    if (entities.empty) {
      Json[size_t][UUID] newEntities;
      _storage[collection] = newEntities;
      entities = newEntities;
    }

    auto json = OOPEntity.toJson;
    foreach(kv; newData.byKeyValue) json[kv.key] = kv.value;

    Json[size_t] entity; 
    entity[json["versionNumber"].get!size_t] = json;
    entities[UUID(json["id"].get!string)] = entity;

    return findOne(collection, json);
  }  
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBFileSource("./tests");
    const json = rep.insertOne("entities", OOPEntity.toJson);
    assert(json != Json(null));
  }
// #endregion create

// #region UpdateMany
  alias updateMany = DESCEntitySource.updateMany;
  override size_t updateMany(string collection, Json select, Json updateData) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return 0;

    auto jsons = findMany(collection, select); 
    foreach(json; jsons) {
      foreach(kv; updateData.byKeyValue) {
        if (kv.key == "id") continue;
        if (kv.key == "versionNumber") continue;

        json[kv.key] = kv.value;
      }
      auto id = UUID(json["id"].get!string);
      auto versionNumber = json["versionNumber"].get!size_t;
      
      entities[id][versionNumber] = json;
    }
    return jsons.length;
  }

  alias updateOne = DESCEntitySource.updateOne;
  override bool updateOne(string collection, Json select, Json updateData) {
    return false; }
 unittest {}
// #endregion update

// #region removeMany by entity  
  alias removeMany = DESCEntitySource.removeMany;
  override size_t removeMany(string collection, UUID id, bool allVersions = false) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return false;

    auto entity = entities.get(id, null);
    if (entity.empty) return false; 

    if (allVersions) {
      auto result = entity.length;
      entities.remove(id);
      return result;
    }

    size_t[] vNumbers = entity.byKey().array;
    entity.remove(vNumbers.maxElement);
    return 1; }
  unittest{}

  override size_t removeMany(string collection, UUID id, size_t versionNumber) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return false;

    auto entity = entities.get(id, null);
    if (entity.empty) return false; 

    if (versionNumber in entity) {
      entity.remove(versionNumber);
      return 1;
    }

    return 0; }
  unittest{}

  override size_t removeMany(string collection, STRINGAA select, bool allVersions = false) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return false;

    size_t result;
    foreach(id, versions; entities) {
      if (allVersions) {
        foreach (vId, vVersion; versions) {
          if (checkVersion(vVersion, select)) {
            result++; 
            versions.remove(vId);
          }
        }
      }
      else {
        size_t vId = versions.byKey().array.maxElement;
        if (checkVersion(versions[vId], select)) {
          result++; 
          versions.remove(vId);
        }
      }
    } 

    return result; }
 unittest {}

  override size_t removeMany(string collection, Json select, bool allVersions = false) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return false;

    size_t result;
    foreach(id, versions; entities) {
      if (allVersions) {
        foreach (vId, vVersion; versions) {
          if (checkVersion(vVersion, select)) {
            result++; 
            versions.remove(vId);
          }
        }
      }
      else {
        size_t vId = versions.byKey().array.maxElement;
        if (checkVersion(versions[vId], select)) {
          result++; 
          versions.remove(vId);
        }
      }
    } 

    return result; }
 unittest {}
// #endregion DeleteMany

// #region removeOne  
  alias removeOne = DESCEntitySource.removeOne;
  override bool removeOne(string collection, UUID id, bool allVersions = false) {
    // Searching for the version of entity
    auto json = findOne(collection, id, allVersions); 
    if (json != Json(null)) { // Entity found
      auto vNumber = json["versionNumber"].get!size_t;
      _storage[collection][id].remove(vNumber);
      if (_storage[collection][id].empty) _storage[collection].remove(id);
      return _storage[collection].get(id, null) == null || _storage[collection][id].get(vNumber, Json(null)) == Json(null); }

    return false; } 
  unittest {
    // debug writeln((StyledString("Test bool removeOne(string collection, UUID id, bool allVersions = false)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBFileSource("./tests");
    auto entity = OOPEntity;
    auto json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    

    entity = OOPEntity;
    json = rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", json));    
  }

  override bool removeOne(string collection, UUID id, size_t versionNumber) {
    auto json = findOne(collection, id, versionNumber); 
    if (json == Json(null)) return false;

    _storage[collection][id].remove(versionNumber);
    if (_storage[collection][id].empty) _storage[collection].remove(id);
    return _storage[collection].get(id, null) == null || _storage[collection][id].get(versionNumber, Json(null)) == Json(null); }
  unittest {
    // debug writeln((StyledString("Test Json insertOne(string collection, Json newData)").setForeground(AnsiColor.black).setBackground(AnsiColor.white)));

    auto rep = EDBFileSource("./tests");
    auto entity = OOPEntity;
    rep.insertOne("entities", entity);
    assert(rep.removeOne("entities", entity.id, entity.versionNumber));    
  }

  override bool removeOne(string collection, STRINGAA select, bool allVersions = false) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return false;
    
    auto json = findOne(collection, select, allVersions); 
    if (json == Json(null)) return false;

    UUID id = UUID(json["id"].get!string);      
    size_t versionNumber = json["versionNumber"].get!size_t;      

    if (id !in entities) return false;
    if (versionNumber !in entities[id]) return false;
    entities[id].remove(versionNumber);

    return _storage[collection].get(id, null) == null || _storage[collection][id].get(versionNumber, Json(null)) == Json(null); }
  unittest {
    auto rep = EDBFileSource("./tests");
    assert(test_removeOne_collection_select(rep));    
    assert(test_removeOne_collection_select_allVersions(rep));
  }

  override bool removeOne(string collection, Json select, bool allVersions = false) {
    auto entities = _storage.get("collection", null);
    if (entities.empty) return false;

    auto json = findOne(collection, select, allVersions); 
    if (json == Json(null)) return false;

    UUID id = UUID(json["id"].get!string);      
    size_t versionNumber = json["versionNumber"].get!size_t;      

    if (id !in entities) return false;
    if (versionNumber !in entities[id]) return false;
    entities[id].remove(versionNumber);

    return _storage[collection].get(id, null) == null || _storage[collection][id].get(versionNumber, Json(null)) == Json(null); }
  unittest {
    auto rep = EDBFileSource("./tests");
    assert(test_removeOne_collection_jsonselect(rep));    
    assert(test_removeOne_collection_jsonselect_allVersions(rep));
  }
// #endregion removeOne

}
auto EDBMemoryentitysource() { return new DEDBMemoryentitysource; }