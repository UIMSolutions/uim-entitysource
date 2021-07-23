module uim.entitysource.entitysource;

@safe:
import uim.entitysource;

abstract class DEDBentitysource {
  this() { this.separator(":"); }

  mixin(SProperty!("string", "separator"));

  DEDBentitysource connect() { return this; }
  DEDBentitysource cleanupConnections() { return this; }

  string[] collections() { return null; }
  
  string uniqueName(string area, string pool, string startName) {
    return uniqueName(area ~ separator ~ pool, startName); }
  string uniqueName(string collection, string startName) {
    string result = startName;
    while (count(collection, ["name": result]) > 0)
      result = startName ~ "-" ~ to!string(uniform(0, 999999));
    return result;
  }

  bool has(_VERSION entity, UUID id) {
    return "id" in entity ? entity["id"].get!string == id.toString : false; }
  unittest {}

  bool has(_VERSION entity, string name) {
    return "name" in entity ? entity["name"].get!string == name : false; }
  unittest {}

  bool has(_VERSION entity, size_t verNumber = 0) {
    return (verNumber == 0) && (versionNumber(entity) == verNumber);
  }
  unittest {}

  Json lastVersion(string colName, UUID id) { return Json(null); }
  size_t lastVersionNumber(string colName, UUID id) { return 0; }
  
  Json[] lastVersions(string colName) {
    Json[] results;
    return results;
  }

  Json[] versions(string colName, UUID id) {
    return null;
  }

  Json[] versions(Json[size_t][UUID] col, UUID id) {
    if (id !in col) return null;
    return col[id].byValue.array; }

  Json[] versions(Json[size_t] entity) { 
    return entity.byValue.array; }

  // #region count
  // Searching in store
  size_t count(UUID[] ids, bool allVersions = false) {
    return ids.map!(a => count(a, allVersions)).sum; }
  size_t count(UUID id, bool allVersions = false) {
    return count(collections, id, allVersions); }

  size_t count(STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => count(a, allVersions)).sum; }
  size_t count(STRINGAA select, bool allVersions = false) {
    return count(collections, select, allVersions); }

  // Searching for existing ids
  size_t count(string[] areas, string[] pools, UUID[] ids, bool allVersions = false) {
    return areas.map!(a => count(a, pools, ids, allVersions)).sum; }
  size_t count(string[] areas, string pool, UUID[] ids, bool allVersions = false) {
    return areas.map!(a => count(a, pool, ids, allVersions)).sum; }
  size_t count(string area, string[] pools, UUID[] ids, bool allVersions = false) {
    return pools.map!(a => count(area, a, ids, allVersions)).sum; }
  size_t count(string area, string pool, UUID[] ids, bool allVersions = false) {
    return ids.map!(a => count(area, pool, a, allVersions)).sum; }
  size_t count(string collection, UUID[] ids, bool allVersions = false) {
    return ids.map!(a => count(collection, a, allVersions)).sum; }

  // Searching for existing id
  size_t count(string[] areas, string[] pools, UUID id, bool allVersions = false) {
    return areas.map!(a => count(a, pools, id, allVersions)).sum; }
  size_t count(string[] areas, string pool, UUID id, bool allVersions = false) {
    return areas.map!(a => count(a, pool, id, allVersions)).sum; }
  size_t count(string area, string[] pools, UUID id, bool allVersions = false) {
    return pools.map!(a => count(area, a, id, allVersions)).sum; }
  size_t count(string area, string pool, UUID id, bool allVersions = false) {
    return count(area ~ separator ~ pool, id, allVersions); }
  size_t count(string[] collections, UUID id, bool allVersions = false) {
    return collections.map!(a => count(a, id, allVersions)).sum; }
  size_t count(string collection, UUID id, bool allVersions = false) {
    return findMany(collection, id, allVersions).length; }

  // Searching for existing ids
  size_t count(string[] areas, string[] pools, UUID[] ids, size_t versionNumber) {
    return areas.map!(a => count(a, pools, ids, versionNumber)).sum; }
  size_t count(string[] areas, string pool, UUID[] ids, size_t versionNumber) {
    return areas.map!(a => count(a, pool, ids, versionNumber)).sum; }
  size_t count(string area, string[] pools, UUID[] ids, size_t versionNumber) {
    return pools.map!(a => count(area, a, ids, versionNumber)).sum; }
  size_t count(string area, string pool, UUID[] ids, size_t versionNumber) {
    return ids.map!(a => count(area, pool, a, versionNumber)).sum; }
  size_t count(string collection, UUID[] ids, size_t versionNumber) {
    return ids.map!(a => count(collection, a, versionNumber)).sum; }

  // Searching for existing id
  size_t count(string[] areas, string[] pools, UUID id, size_t versionNumber) {
    return areas.map!(a => count(a, pools, id, versionNumber)).sum; }
  size_t count(string[] areas, string pool, UUID id, size_t versionNumber) {
    return areas.map!(a => count(a, pool, id, versionNumber)).sum; }
  size_t count(string area, string[] pools, UUID id, size_t versionNumber) {
    return pools.map!(a => count(area, a, id, versionNumber)).sum; }
  size_t count(string area, string pool, UUID id, size_t versionNumber) {
    return count(area ~ separator ~ pool, id, versionNumber); }
  size_t count(string[] collections, UUID id, size_t versionNumber) {
    return collections.map!(a => count(a, id, versionNumber)).sum; }
  size_t count(string collection, UUID id, size_t versionNumber) {
    return findMany(collection, id, versionNumber).length; }

  // Searching for existing selects
  size_t count(string[] areas, string[] pools, STRINGAA[] selects, bool allVersions = false) {
    return areas.map!(a => count(a, pools, selects, allVersions)).sum; }
  size_t count(string[] areas, string pool, STRINGAA[] selects, bool allVersions = false) {
    return areas.map!(a => count(a, pool, selects, allVersions)).sum; }
  size_t count(string area, string[] pools, STRINGAA[] selects, bool allVersions = false) {
    return pools.map!(a => count(area, a, selects, allVersions)).sum; }
  size_t count(string area, string pool, STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => count(area, pool, a, allVersions)).sum; }
  size_t count(string collection, STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => count(collection, a, allVersions)).sum; }

  // Searching based on parameter "select":string[string]
  size_t count(string[] areas, string[] pools, STRINGAA select, bool allVersions = false) {
    return areas.map!(a => count(a, pools, select, allVersions)).sum; }
  size_t count(string[] areas, string pool, STRINGAA select, bool allVersions = false) {
    return areas.map!(a => count(a, pool, select, allVersions)).sum; }
  size_t count(string area, string[] pools, STRINGAA select, bool allVersions = false) {
    return pools.map!(a => count(area, a, select, allVersions)).sum; }
  size_t count(string area, string pool, STRINGAA select, bool allVersions = false) {
    return count(area ~ separator ~ pool, select, allVersions); }
  size_t count(string[] collections, STRINGAA select, bool allVersions = false) {
    return collections.map!(a => count(a, select, allVersions)).sum; }
  size_t count(string collection, STRINGAA select, bool allVersions = false) {
    return findMany(collection, select, allVersions).length; }

  // Searching for existing selects:json[]
  size_t count(string[] areas, string[] pools, Json[] selects, bool allVersions = false) {
    return areas.map!(a => count(a, pools, selects, allVersions)).sum; }
  size_t count(string[] areas, string pool, Json[] selects, bool allVersions = false) {
    return areas.map!(a => count(a, pool, selects, allVersions)).sum; }
  size_t count(string area, string[] pools, Json[] selects, bool allVersions = false) {
    return pools.map!(a => count(area, a, selects, allVersions)).sum; }
  size_t count(string area, string pool, Json[] selects, bool allVersions = false) {
    return selects.map!(a => count(area, pool, a, allVersions)).sum; }
  size_t count(string collection, Json[] selects, bool allVersions = false) {
    return selects.map!(a => count(collection, a, allVersions)).sum; }

  // Searching based on parameter "select":Json[]
  size_t count(string[] areas, string[] pools, Json select, bool allVersions = false) {
    return areas.map!(a => count(a, pools, select, allVersions)).sum; }
  size_t count(string[] areas, string pool, Json select, bool allVersions = false) {
    return areas.map!(a => count(a, pool, select, allVersions)).sum; }
  size_t count(string area, string[] pools, Json select, bool allVersions = false) {
    return pools.map!(a => count(area, a, select, allVersions)).sum; }
  size_t count(string area, string pool, Json select, bool allVersions = false) {
    return count(area ~ separator ~ pool, select, allVersions); }
  size_t count(string[] collections, Json select, bool allVersions = false) {
    return collections.map!(a => count(a, select, allVersions)).sum; }
  size_t count(string collection, Json select, bool allVersions = false) {
    return findMany(collection, select, allVersions).length; }

  // Searching for existing entities (id & versionNumber)
  size_t count(string[] areas, string[] pools, DOOPEntity[] entities) {
    return areas.map!(a => count(a, pools, entities)).sum; }
  size_t count(string[] areas, string pool, DOOPEntity[] entities) {
    return areas.map!(a => count(a, pool, entities)).sum; }
  size_t count(string area, string[] pools, DOOPEntity[] entities) {
    return pools.map!(a => count(area, a, entities)).sum; }
  size_t count(string area, string pool, DOOPEntity[] entities) {
    return entities.map!(a => count(area, pool, a)).sum; }
  size_t count(string collection, DOOPEntity[] entities) {
    return entities.map!(a => count(collection, a)).sum; }

  // Searching based on parameter entity (id & versionNumber)
  size_t count(string[] areas, string[] pools, DOOPEntity entity) {
    return areas.map!(a => count(a, pools, entity)).sum; }
  size_t count(string[] areas, string pool, DOOPEntity entity) {
    return areas.map!(a => count(a, pool, entity)).sum; }
  size_t count(string area, string[] pools, DOOPEntity entity) {
    return pools.map!(a => count(area, a, entity)).sum; }
  size_t count(string area, string pool, DOOPEntity entity) {
    return count(area ~ separator ~ pool, entity); }
  size_t count(string[] collections, DOOPEntity entity) {
    return collections.map!(a => count(a, entity)).sum; }
  size_t count(string collection, DOOPEntity entity) {
    return findMany(collection, entity).length; }
  // #endregion

// #region read
  // Searching in store
  Json[] findMany(bool allVersions = false) {
    return findMany(collections, allVersions); }

  Json[] findMany(string[] collections, bool allVersions = false) {
    return collections.map!(a => findMany(a, allVersions)).join; }
  Json[] findMany(string collection, bool allVersions = false) {
    return []; }

  Json[] findMany(UUID[] ids, bool allVersions = false) {
    return ids.map!(a => findMany(a, allVersions)).join; }
  Json[] findMany(UUID id, bool allVersions = false) {
    return findMany(collections, id, allVersions); }

  Json[] findMany(STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => findMany(a, allVersions)).join; }
  Json[] findMany(STRINGAA select, bool allVersions = false) {
    return findMany(collections, select, allVersions); }

  // Searching for existing entities (id & versionNumber)
  Json[] findMany(string[] areas, string[] pools, DOOPEntity[] entities) {
    return areas.map!(a => findMany(a, pools, entities)).join; }
  Json[] findMany(string[] areas, string pool, DOOPEntity[] entities) {
    return areas.map!(a => findMany(a, pool, entities)).join; }
  Json[] findMany(string area, string[] pools, DOOPEntity[] entities) {
    return pools.map!(a => findMany(area, a, entities)).join; }
  Json[] findMany(string area, string pool, DOOPEntity[] entities) {
    return entities.map!(a => findMany(area, pool, a)).join; }
  Json[] findMany(string collection, DOOPEntity[] entities) {
    return entities.map!(a => findMany(collection, a)).join; }

  // Searching based on parameter entity (id & versionNumber)
  Json[] findMany(string[] areas, string[] pools, DOOPEntity entity) {
    return areas.map!(a => findMany(a, pools, entity)).join; }
  Json[] findMany(string[] areas, string pool, DOOPEntity entity) {
    return areas.map!(a => findMany(a, pool, entity)).join; }
  Json[] findMany(string area, string[] pools, DOOPEntity entity) {
    return pools.map!(a => findMany(area, a, entity)).join; }
  Json[] findMany(string area, string pool, DOOPEntity entity) {
    return findMany(area ~ separator ~ pool, entity); }
  Json[] findMany(string[] collections, DOOPEntity entity) {
    return collections.map!(a => findMany(a, entity)).join; }
  Json[] findMany(string collection, DOOPEntity entity) {
    return findMany(collection, entity.id, entity.versionNumber); }

  // Searching for existing ids
  Json[] findMany(string[] areas, string[] pools, UUID[] ids, bool allVersions = false) {
    return areas.map!(a => findMany(a, pools, ids, allVersions)).join; }
  Json[] findMany(string[] areas, string pool, UUID[] ids, bool allVersions = false) {
    return areas.map!(a => findMany(a, pool, ids, allVersions)).join; }
  Json[] findMany(string area, string[] pools, UUID[] ids, bool allVersions = false) {
    return pools.map!(a => findMany(area, a, ids, allVersions)).join; }
  Json[] findMany(string area, string pool, UUID[] ids, bool allVersions = false) {
    return ids.map!(a => findMany(area, pool, a, allVersions)).join; }
  Json[] findMany(string collection, UUID[] ids, bool allVersions = false) {
    return ids.map!(a => findMany(collection, a, allVersions)).join; }

  // Searching for existing id
  Json[] findMany(string[] areas, string[] pools, UUID id, bool allVersions = false) {
    return areas.map!(a => findMany(a, pools, id, allVersions)).join; }
  Json[] findMany(string[] areas, string pool, UUID id, bool allVersions = false) {
    return areas.map!(a => findMany(a, pool, id, allVersions)).join; }
  Json[] findMany(string area, string[] pools, UUID id, bool allVersions = false) {
    return pools.map!(a => findMany(area, a, id, allVersions)).join; }
  Json[] findMany(string area, string pool, UUID id, bool allVersions = false) {
    return findMany(area ~ separator ~ pool, id, allVersions); }
  Json[] findMany(string[] collections, UUID id, bool allVersions = false) {
    return collections.map!(a => findMany(a, id, allVersions)).join; }
  Json[] findMany(string collection, UUID id, bool allVersions = false) {
    return null; }

  // Searching for existing ids & versionNumber
  Json[] findMany(string[] areas, string[] pools, UUID[] ids, size_t versionNumber) {
    return areas.map!(a => findMany(a, pools, ids, versionNumber)).join; }
  Json[] findMany(string[] areas, string pool, UUID[] ids, size_t versionNumber) {
    return areas.map!(a => findMany(a, pool, ids, versionNumber)).join; }
  Json[] findMany(string area, string[] pools, UUID[] ids, size_t versionNumber) {
    return pools.map!(a => findMany(area, a, ids, versionNumber)).join; }
  Json[] findMany(string area, string pool, UUID[] ids, size_t versionNumber) {
    return ids.map!(a => findMany(area, pool, a, versionNumber)).join; }
  Json[] findMany(string collection, UUID[] ids, size_t versionNumber) {
    return ids.map!(a => findMany(collection, a, versionNumber)).join; }

  // Searching for existing id & number
  Json[] findMany(string[] areas, string[] pools, UUID id, size_t versionNumber) {
    return areas.map!(a => findMany(a, pools, id, versionNumber)).join; }
  Json[] findMany(string[] areas, string pool, UUID id, size_t versionNumber) {
    return areas.map!(a => findMany(a, pool, id, versionNumber)).join; }
  Json[] findMany(string area, string[] pools, UUID id, size_t versionNumber) {
    return pools.map!(a => findMany(area, a, id, versionNumber)).join; }
  Json[] findMany(string area, string pool, UUID id, size_t versionNumber) {
    return findMany(area ~ separator ~ pool, id, versionNumber); }
  Json[] findMany(string[] collections, UUID id, size_t versionNumber) {
    return collections.map!(a => findMany(a, id, versionNumber)).join; }
  Json[] findMany(string collection, UUID id, size_t versionNumber) {
    return null; }

  // Searching for existing selects
  Json[] findMany(string[] areas, string[] pools, STRINGAA[] selects, bool allVersions = false) {
    return areas.map!(a => findMany(a, pools, selects, allVersions)).join; }
  Json[] findMany(string[] areas, string pool, STRINGAA[] selects, bool allVersions = false) {
    return areas.map!(a => findMany(a, pool, selects, allVersions)).join; }
  Json[] findMany(string area, string[] pools, STRINGAA[] selects, bool allVersions = false) {
    return pools.map!(a => findMany(area, a, selects, allVersions)).join; }
  Json[] findMany(string area, string pool, STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => findMany(area, pool, a, allVersions)).join; }
  Json[] findMany(string collection, STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => findMany(collection, a, allVersions)).join; }

  // Searching based on parameter "select":string[string]
  Json[] findMany(string[] areas, string[] pools, STRINGAA select, bool allVersions = false) {
    return areas.map!(a => findMany(a, pools, select, allVersions)).join; }
  Json[] findMany(string[] areas, string pool, STRINGAA select, bool allVersions = false) {
    return areas.map!(a => findMany(a, pool, select, allVersions)).join; }
  Json[] findMany(string area, string[] pools, STRINGAA select, bool allVersions = false) {
    return pools.map!(a => findMany(area, a, select, allVersions)).join; }
  Json[] findMany(string area, string pool, STRINGAA select, bool allVersions = false) {
    return findMany(area ~ separator ~ pool, select, allVersions); }
  Json[] findMany(string[] collections, STRINGAA select, bool allVersions = false) {
    return collections.map!(a => findMany(a, select, allVersions)).join; }
  Json[] findMany(string collection, STRINGAA select, bool allVersions = false) {
    return null; }

  // Searching for existing selects:json[]
  Json[] findMany(string[] areas, string[] pools, Json[] selects, bool allVersions = false) {
    return areas.map!(a => findMany(a, pools, selects, allVersions)).join; }
  Json[] findMany(string[] areas, string pool, Json[] selects, bool allVersions = false) {
    return areas.map!(a => findMany(a, pool, selects, allVersions)).join; }
  Json[] findMany(string area, string[] pools, Json[] selects, bool allVersions = false) {
    return pools.map!(a => findMany(area, a, selects, allVersions)).join; }
  Json[] findMany(string area, string pool, Json[] selects, bool allVersions = false) {
    return selects.map!(a => findMany(area, pool, a, allVersions)).join; }
  Json[] findMany(string collection, Json[] selects, bool allVersions = false) {
    return selects.map!(a => findMany(collection, a, allVersions)).join; }

  // Searching based on parameter "select":Json[]
  Json[] findMany(string[] areas, string[] pools, Json select, bool allVersions = false) {
    return areas.map!(a => findMany(a, pools, select, allVersions)).join; }
  Json[] findMany(string[] areas, string pool, Json select, bool allVersions = false) {
    return areas.map!(a => findMany(a, pool, select, allVersions)).join; }
  Json[] findMany(string area, string[] pools, Json select, bool allVersions = false) {
    return pools.map!(a => findMany(area, a, select, allVersions)).join; }
  Json[] findMany(string area, string pool, Json select, bool allVersions = false) {
    return findMany(area ~ separator ~ pool, select, allVersions); }
  Json[] findMany(string[] collections, Json select, bool allVersions = false) {
    return collections.map!(a => findMany(a, select, allVersions)).join; }
  Json[] findMany(string collection, Json select, bool allVersions = false) {
    return []; }
// #endregion

// #region findOne
  // Searching in store
  Json findOne(bool allVersions = false) {
    return findOne(collections, allVersions); }

  Json findOne(string[] collections, bool allVersions = false) {
    auto jsons = collections.map!(a => findOne(a, allVersions)).array;
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, bool allVersions = false) {
    return Json(null); }

  Json findOne(UUID[] ids, bool allVersions = false) {
    auto jsons = ids.map!(a => findOne(a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(UUID id, bool allVersions = false) {
    return findOne(collections, id, allVersions); }

  Json findOne(STRINGAA[] selects, bool allVersions = false) {
    auto jsons = selects.map!(a => findOne(a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(STRINGAA select, bool allVersions = false) {
    return findOne(collections, select, allVersions); }

  // Searching for existing entities (id & versionNumber)
  Json findOne(string[] areas, string[] pools, DOOPEntity[] entities) {
    auto jsons = areas.map!(a => findOne(a, pools, entities)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, DOOPEntity[] entities) {
    auto jsons = areas.map!(a => findOne(a, pool, entities)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, DOOPEntity[] entities) {
    auto jsons = pools.map!(a => findOne(area, a, entities)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, DOOPEntity[] entities) {
    auto jsons = entities.map!(a => findOne(area, pool, a)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, DOOPEntity[] entities) {
    auto jsons = entities.map!(a => findOne(collection, a)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }

  // Searching based on parameter entity (id & versionNumber)
  Json findOne(string[] areas, string[] pools, DOOPEntity entity) {
    auto jsons = areas.map!(a => findOne(a, pools, entity)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, DOOPEntity entity) {
    auto jsons = areas.map!(a => findOne(a, pool, entity)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, DOOPEntity entity) {
    auto jsons = pools.map!(a => findOne(area, a, entity)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, DOOPEntity entity) {
    return findOne(area ~ separator ~ pool, entity); }
  Json findOne(string[] collections, DOOPEntity entity) {
    auto jsons = collections.map!(a => findOne(a, entity)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, DOOPEntity entity) {
    return findOne(collection, entity.id, entity.versionNumber); }

  // Searching for existing ids
  Json findOne(string[] areas, string[] pools, UUID[] ids, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pools, ids, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, UUID[] ids, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pool, ids, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, UUID[] ids, bool allVersions = false) {
    auto jsons = pools.map!(a => findOne(area, a, ids, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, UUID[] ids, bool allVersions = false) {
    auto jsons = ids.map!(a => findOne(area, pool, a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, UUID[] ids, bool allVersions = false) {
    auto jsons = ids.map!(a => findOne(collection, a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }

  // Searching for existing id
  Json findOne(string[] areas, string[] pools, UUID id, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pools, id, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, UUID id, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pool, id, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, UUID id, bool allVersions = false) {
    auto jsons = pools.map!(a => findOne(area, a, id, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, UUID id, bool allVersions = false) {
    return findOne(area ~ separator ~ pool, id, allVersions); }
  Json findOne(string[] collections, UUID id, bool allVersions = false) {
    auto jsons = collections.map!(a => findOne(a, id, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, UUID id, bool allVersions = false) {
    return Json(null); }

  // Searching for existing ids & versionNumber
  Json findOne(string[] areas, string[] pools, UUID[] ids, size_t versionNumber) {
    auto jsons = areas.map!(a => findOne(a, pools, ids, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, UUID[] ids, size_t versionNumber) {
    auto jsons = areas.map!(a => findOne(a, pool, ids, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, UUID[] ids, size_t versionNumber) {
    auto jsons = pools.map!(a => findOne(area, a, ids, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, UUID[] ids, size_t versionNumber) {
    auto jsons = ids.map!(a => findOne(area, pool, a, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, UUID[] ids, size_t versionNumber) {
    auto jsons = ids.map!(a => findOne(collection, a, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }

  // Searching for existing id & number
  Json findOne(string[] areas, string[] pools, UUID id, size_t versionNumber) {
    auto jsons = areas.map!(a => findOne(a, pools, id, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, UUID id, size_t versionNumber) {
    auto jsons = areas.map!(a => findOne(a, pool, id, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, UUID id, size_t versionNumber) {
    auto jsons = pools.map!(a => findOne(area, a, id, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, UUID id, size_t versionNumber) {
    return findOne(area ~ separator ~ pool, id, versionNumber); }
  Json findOne(string[] collections, UUID id, size_t versionNumber) {
    auto jsons = collections.map!(a => findOne(a, id, versionNumber)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, UUID id, size_t versionNumber) {
    return Json(null); }

  // Searching for existing selects
  Json findOne(string[] areas, string[] pools, STRINGAA[] selects, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pools, selects, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, STRINGAA[] selects, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pool, selects, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, STRINGAA[] selects, bool allVersions = false) {
    auto jsons = pools.map!(a => findOne(area, a, selects, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, STRINGAA[] selects, bool allVersions = false) {
    auto jsons = selects.map!(a => findOne(area, pool, a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, STRINGAA[] selects, bool allVersions = false) {
    auto jsons = selects.map!(a => findOne(collection, a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }

  // Searching based on parameter "select":string[string]
  Json findOne(string[] areas, string[] pools, STRINGAA select, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pools, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, STRINGAA select, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pool, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, STRINGAA select, bool allVersions = false) {
    auto jsons = pools.map!(a => findOne(area, a, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, STRINGAA select, bool allVersions = false) {
    return findOne(area ~ separator ~ pool, select, allVersions); }
  Json findOne(string[] collections, STRINGAA select, bool allVersions = false) {
    auto jsons = collections.map!(a => findOne(a, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, STRINGAA select, bool allVersions = false) {
    return Json(null); }

  // Searching for existing selects:json[]
  Json findOne(string[] areas, string[] pools, Json[] selects, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pools, selects, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, Json[] selects, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pool, selects, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, Json[] selects, bool allVersions = false) {
    auto jsons = pools.map!(a => findOne(area, a, selects, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, Json[] selects, bool allVersions = false) {
    auto jsons = selects.map!(a => findOne(area, pool, a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, Json[] selects, bool allVersions = false) {
    auto jsons = selects.map!(a => findOne(collection, a, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }

  // Searching based on parameter "select":Json[]
  Json findOne(string[] areas, string[] pools, Json select, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pools, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string[] areas, string pool, Json select, bool allVersions = false) {
    auto jsons = areas.map!(a => findOne(a, pool, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string[] pools, Json select, bool allVersions = false) {
    auto jsons = pools.map!(a => findOne(area, a, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string area, string pool, Json select, bool allVersions = false) {
    return findOne(area ~ separator ~ pool, select, allVersions); }
  Json findOne(string[] collections, Json select, bool allVersions = false) {
    auto jsons = collections.map!(a => findOne(a, select, allVersions)).array; 
    return jsons.length > 0 ? jsons[0] : Json(null); }
  Json findOne(string collection, Json select, bool allVersions = false) {
    return Json(null); }
// #endregion

// #region create
  Json[] insertMany(string area, string pool, DOOPEntity[] entities) {
    return insertMany(area ~ separator ~ pool, entities); }
  Json[] insertMany(string collection, DOOPEntity[] entities) {
    return entities.map!(entity => insertOne(collection, entity)).array; }

  Json[] insertMany(string area, string pool, Json[] jsons) {
    return insertMany(area ~ separator ~ pool, jsons); }
  Json[] insertMany(string collection, Json[] jsons) {
    return jsons.map!(json => insertOne(collection, json)).array; }

  Json insertOne(string area, string pool, DOOPEntity createData) {
    return insertOne(area ~ separator ~ pool, createData); }
  Json insertOne(string collection, DOOPEntity createData) {
    return insertOne(collection, createData.toJson); }

  Json insertOne(string area, string pool, Json createData) {
    return insertOne(area ~ separator ~ pool, createData); }
  Json insertOne(string collection, Json newData) {
    return Json(null); }
// #endregion

// #region update
/*   size_t updateMany(string area, string pool, DOOPEntity updateEntity) {
    return updateMany(area ~ separator ~ pool, updateEntity); }
  size_t updateMany(string collection, DOOPEntity updateEntity) {
    return updateMany(collection, updateEntity.toJson(["id", "versionNumber"]), updateEntity.toJson);
  }

  size_t updateMany(string area, string pool, STRINGAA select, DOOPEntity updateEntity) {
    return this.updateMany(area ~ separator ~ pool, select, updateEntity); }
  size_t updateMany(string collection, STRINGAA select, DOOPEntity updateEntity) {
    return updateMany(collection, select, updateEntity.toJson);
  }

  size_t updateMany(string area, string pool, Json select, DOOPEntity updateEntity) {
    return updateMany(area ~ separator ~ pool, select, updateEntity); }
  size_t updateMany(string collection, Json select, DOOPEntity updateEntity) {
    return updateMany(collection, select, updateEntity.toJson); } */

  size_t updateMany(string area, string pool, STRINGAA select, Json updateData) {
    return updateMany(area ~ separator ~ pool, select, updateData); }
  size_t updateMany(string collection, STRINGAA select, Json updateData) {
    return updateMany(collection, select.serializeToJson, updateData); }

  size_t updateMany(string area, string pool, Json select, Json updateData) {
    return updateMany(area ~ separator ~ pool, select, updateData); }
  size_t updateMany(string collection, Json select, Json updateData) {
    return 0; }
// #endregion

// #region update
  bool updateOne(string area, string pool, DOOPEntity updateEntity) {
    return updateOne(area ~ separator ~ pool, updateEntity); }
  bool updateOne(string collection, DOOPEntity updateEntity) {
    return updateOne(collection, updateEntity.toJson(["id", "versionNumber"]), updateEntity.toJson);
  }

  bool updateOne(string area, string pool, STRINGAA select, DOOPEntity updateEntity) {
    return this.updateOne(area ~ separator ~ pool, select, updateEntity); }
  bool updateOne(string collection, STRINGAA select, DOOPEntity updateEntity) {
    return updateOne(collection, select, updateEntity.toJson);
  }

  bool updateOne(string area, string pool, Json select, DOOPEntity updateEntity) {
    return updateOne(area ~ separator ~ pool, select, updateEntity); }
  bool updateOne(string collection, Json select, DOOPEntity updateEntity) {
    return updateOne(collection, select, updateEntity.toJson); }

  bool updateOne(string area, string pool, STRINGAA select, Json updateData) {
    return updateOne(area ~ separator ~ pool, select, updateData); }
  bool updateOne(string collection, STRINGAA select, Json updateData) {
    return updateOne(collection, select.serializeToJson, updateData); }

  bool updateOne(string area, string pool, Json select, Json updateData) {
    return updateOne(area ~ separator ~ pool, select, updateData); }
  bool updateOne(string collection, Json select, Json updateData) {
    return false; }
// #endregion

// #region removeMany by entity  
  size_t removeMany(STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => removeMany(a, allVersions)).sum; }
  size_t removeMany(STRINGAA select, bool allVersions = false) {
    return removeMany(collections, select, allVersions); }
  
  // #region removeMany by entity  
    size_t removeMany(string[] areas, string[] pools, DOOPEntity[] entities) {
      return areas.map!(a => removeMany(a, pools, entities)).sum; }
    size_t removeMany(string[] areas, string pool, DOOPEntity[] entities) {
      return areas.map!(a => removeMany(a, pool, entities)).sum; }
    size_t removeMany(string area, string[] pools, DOOPEntity[] entities) {
      return pools.map!(a => removeMany(area, a, entities)).sum; }
    size_t removeMany(string area, string pool, DOOPEntity[] entities) {
      return entities.map!(a => removeMany(area, pool, a)).sum; }
    size_t removeMany(string collection, DOOPEntity[] entities) {
      return entities.map!(a => removeMany(collection, a)).sum; }

    size_t removeMany(string[] areas, string[] pools, DOOPEntity entity) {
      return areas.map!(a => removeMany(a, pools, entity)).sum; }
    size_t removeMany(string[] areas, string pool, DOOPEntity entity) {
      return areas.map!(a => removeMany(a, pool, entity)).sum; }
    size_t removeMany(string area, string[] pools, DOOPEntity entity) {
      return pools.map!(a => removeMany(area, a, entity)).sum; }
    size_t removeMany(string area, string pool, DOOPEntity entity) {
      return removeMany(area ~ separator ~ pool, entity); }
    size_t removeMany(string[] collections, DOOPEntity entity) {
      return collections.map!(a => removeMany(a, entity)).sum; }
    size_t removeMany(string collection, DOOPEntity entity) { 
      return removeMany(collection, entity.id, entity.versionNumber); }
  // #endregion 

  // #region Remove by id 
    size_t removeMany(UUID[] ids, bool allVersions = false) {
      return ids.map!(a => removeMany(a, allVersions)).sum; }
    size_t removeMany(UUID id, bool allVersions = false) {
      return removeMany(collections, id, allVersions); }

    size_t removeMany(string[] areas, string[] pools, UUID[] ids, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pools, ids, allVersions)).sum; }
    size_t removeMany(string[] areas, string pool, UUID[] ids, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pool, ids, allVersions)).sum; }
    size_t removeMany(string area, string[] pools, UUID[] ids, bool allVersions = false) {
      return pools.map!(a => removeMany(area, a, ids, allVersions)).sum; }
    size_t removeMany(string area, string pool, UUID[] ids, bool allVersions = false) {
      return ids.map!(a => removeMany(area, pool, a, allVersions)).sum; }
    size_t removeMany(string collection, UUID[] ids, bool allVersions = false) {
      return ids.map!(a => removeMany(collection, a, allVersions)).sum; }

    size_t removeMany(string[] areas, string[] pools, UUID id, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pools, id, allVersions)).sum; }
    size_t removeMany(string[] areas, string pool, UUID id, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pool, id, allVersions)).sum; }
    size_t removeMany(string area, string[] pools, UUID id, bool allVersions = false) {
      return pools.map!(a => removeMany(area, a, id, allVersions)).sum; }
    size_t removeMany(string area, string pool, UUID id, bool allVersions = false) {
      return removeMany(area ~ separator ~ pool, id, allVersions); }
    size_t removeMany(string[] collections, UUID id, bool allVersions = false) {
      return collections.map!(a => removeMany(a, id, allVersions)).sum; }
    size_t removeMany(string collection, UUID id, bool allVersions = false) {
      return 0; }
  // #endregion Remove by id 

  // #region Remove by id & versionNumber
    size_t removeMany(UUID[] ids, size_t versionNumber) {
      return ids.map!(a => removeMany(a, versionNumber)).sum; }
    size_t removeMany(UUID id, size_t versionNumber) {
      return removeMany(collections, id, versionNumber); }

    size_t removeMany(string[] areas, string[] pools, UUID[] ids, size_t versionNumber) {
      return areas.map!(a => removeMany(a, pools, ids, versionNumber)).sum; }
    size_t removeMany(string[] areas, string pool, UUID[] ids, size_t versionNumber) {
      return areas.map!(a => removeMany(a, pool, ids, versionNumber)).sum; }
    size_t removeMany(string area, string[] pools, UUID[] ids, size_t versionNumber) {
      return pools.map!(a => removeMany(area, a, ids, versionNumber)).sum; }
    size_t removeMany(string area, string pool, UUID[] ids, size_t versionNumber) {
      return ids.map!(a => removeMany(area, pool, a, versionNumber)).sum; }
    size_t removeMany(string collection, UUID[] ids, size_t versionNumber) {
      return ids.map!(a => removeMany(collection, a, versionNumber)).sum; }

    size_t removeMany(string[] areas, string[] pools, UUID id, size_t versionNumber) {
      return areas.map!(a => removeMany(a, pools, id, versionNumber)).sum; }
    size_t removeMany(string[] areas, string pool, UUID id, size_t versionNumber) {
      return areas.map!(a => removeMany(a, pool, id, versionNumber)).sum; }
    size_t removeMany(string area, string[] pools, UUID id, size_t versionNumber) {
      return pools.map!(a => removeMany(area, a, id, versionNumber)).sum; }
    size_t removeMany(string area, string pool, UUID id, size_t versionNumber) {
      return removeMany(area ~ separator ~ pool, id, versionNumber); }
    size_t removeMany(string[] collections, UUID id, size_t versionNumber) {
      return collections.map!(a => removeMany(a, id, versionNumber)).sum; }
    size_t removeMany(string collection, UUID id, size_t versionNumber) {
      return 0; }
  // #endregion

  // #region RemoveMany by select (string[string])
    size_t removeMany(string[] areas, string[] pools, STRINGAA[] selects, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pools, selects, allVersions)).sum; }
    size_t removeMany(string[] areas, string pool, STRINGAA[] selects, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pool, selects, allVersions)).sum; }
    size_t removeMany(string area, string[] pools, STRINGAA[] selects, bool allVersions = false) {
      return pools.map!(a => removeMany(area, a, selects, allVersions)).sum; }
    size_t removeMany(string area, string pool, STRINGAA[] selects, bool allVersions = false) {
      return selects.map!(a => removeMany(area, pool, a, allVersions)).sum; }
    size_t removeMany(string collection, STRINGAA[] selects, bool allVersions = false) {
      return selects.map!(a => removeMany(collection, a, allVersions)).sum; }

    size_t removeMany(string[] areas, string[] pools, STRINGAA select, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pools, select, allVersions)).sum; }
    size_t removeMany(string[] areas, string pool, STRINGAA select, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pool, select, allVersions)).sum; }
    size_t removeMany(string area, string[] pools, STRINGAA select, bool allVersions = false) {
      return pools.map!(a => removeMany(area, a, select, allVersions)).sum; }
    size_t removeMany(string area, string pool, STRINGAA select, bool allVersions = false) {
      return removeMany(area ~ separator ~ pool, select, allVersions); }
    size_t removeMany(string[] collections, STRINGAA select, bool allVersions = false) {
      return collections.map!(a => removeMany(a, select, allVersions)).sum; }
    size_t removeMany(string collection, STRINGAA select, bool allVersions = false) {
      return 0; }
  // #endregion RemoveMany by select (string[string])

  // #region Remove By json
    size_t removeMany(string[] areas, string[] pools, Json[] selects, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pools, selects, allVersions)).sum; }
    size_t removeMany(string[] areas, string pool, Json[] selects, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pool, selects, allVersions)).sum; }
    size_t removeMany(string area, string[] pools, Json[] selects, bool allVersions = false) {
      return pools.map!(a => removeMany(area, a, selects, allVersions)).sum; }
    size_t removeMany(string area, string pool, Json[] selects, bool allVersions = false) {
      return selects.map!(a => removeMany(area, pool, a, allVersions)).sum; }
    size_t removeMany(string collection, Json[] selects, bool allVersions = false) {
      return selects.map!(a => removeMany(collection, a, allVersions)).sum; }
  // #endregion Remove By json

  // #region Searching based on parameter "select":Json[]
    size_t removeMany(string[] areas, string[] pools, Json select, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pools, select, allVersions)).sum; }
    size_t removeMany(string[] areas, string pool, Json select, bool allVersions = false) {
      return areas.map!(a => removeMany(a, pool, select, allVersions)).sum; }
    size_t removeMany(string area, string[] pools, Json select, bool allVersions = false) {
      return pools.map!(a => removeMany(area, a, select, allVersions)).sum; }
    size_t removeMany(string area, string pool, Json select, bool allVersions = false) {
      return removeMany(area ~ separator ~ pool, select, allVersions); }
    size_t removeMany(string[] collections, Json select, bool allVersions = false) {
      return collections.map!(a => removeMany(a, select, allVersions)).sum; }
    size_t removeMany(string collection, Json select, bool allVersions = false) {
      auto jsons = findMany(collection, select, allVersions);
      return jsons.map!(a => removeOne(collection, a) ? 1 : 0).sum; }
  // #endregion Searching based on parameter "select":Json[]
// #endregion RemoveMany

// #region removeOne by entity  
  bool removeOne(STRINGAA[] selects, bool allVersions = false) {
    return selects.map!(a => removeOne(a, allVersions)).sum > 0; }
  bool removeOne(STRINGAA select, bool allVersions = false) {
    return removeOne(collections, select, allVersions); }
  
  // #region removeMany by entity  
    bool removeOne(string[] areas, string[] pools, DOOPEntity[] entities) {
      return areas.map!(a => removeOne(a, pools, entities)).sum > 0; }
    bool removeOne(string[] areas, string pool, DOOPEntity[] entities) {
      return areas.map!(a => removeOne(a, pool, entities)).sum > 0; }
    bool removeOne(string area, string[] pools, DOOPEntity[] entities) {
      return pools.map!(a => removeOne(area, a, entities)).sum > 0; }
    bool removeOne(string area, string pool, DOOPEntity[] entities) {
      return entities.map!(a => removeOne(area, pool, a)).sum > 0; }
    bool removeOne(string collection, DOOPEntity[] entities) {
      return entities.map!(a => removeOne(collection, a)).sum > 0; }

    bool removeOne(string[] areas, string[] pools, DOOPEntity entity) {
      return areas.map!(a => removeOne(a, pools, entity)).sum > 0; }
    bool removeOne(string[] areas, string pool, DOOPEntity entity) {
      return areas.map!(a => removeOne(a, pool, entity)).sum > 0; }
    bool removeOne(string area, string[] pools, DOOPEntity entity) {
      return pools.map!(a => removeOne(area, a, entity)).sum > 0; }
    bool removeOne(string area, string pool, DOOPEntity entity) {
      return removeOne(area ~ separator ~ pool, entity); }
    bool removeOne(string[] collections, DOOPEntity entity) {
      return collections.map!(a => removeOne(a, entity)).sum > 0; }
    bool removeOne(string collection, DOOPEntity entity) { 
      return removeOne(collection, entity.id, entity.versionNumber); }
  // #endregion 

  // #region Remove by id 
    bool removeOne(UUID[] ids, bool allVersions = false) {
      return ids.map!(a => removeOne(a, allVersions)).sum > 0; }
    bool removeOne(UUID id, bool allVersions = false) {
      return removeOne(collections, id, allVersions); }

    bool removeOne(string[] areas, string[] pools, UUID[] ids, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pools, ids, allVersions)).sum > 0; }
    bool removeOne(string[] areas, string pool, UUID[] ids, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pool, ids, allVersions)).sum > 0; }
    bool removeOne(string area, string[] pools, UUID[] ids, bool allVersions = false) {
      return pools.map!(a => removeOne(area, a, ids, allVersions)).sum > 0; }
    bool removeOne(string area, string pool, UUID[] ids, bool allVersions = false) {
      return ids.map!(a => removeOne(area, pool, a, allVersions)).sum > 0; }
    bool removeOne(string collection, UUID[] ids, bool allVersions = false) {
      return ids.map!(a => removeOne(collection, a, allVersions)).sum > 0; }

    bool removeOne(string[] areas, string[] pools, UUID id, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pools, id, allVersions)).sum > 0; }
    bool removeOne(string[] areas, string pool, UUID id, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pool, id, allVersions)).sum > 0; }
    bool removeOne(string area, string[] pools, UUID id, bool allVersions = false) {
      return pools.map!(a => removeOne(area, a, id, allVersions)).sum > 0; }
    bool removeOne(string area, string pool, UUID id, bool allVersions = false) {
      return removeOne(area ~ separator ~ pool, id, allVersions); }
    bool removeOne(string[] collections, UUID id, bool allVersions = false) {
      return collections.map!(a => removeOne(a, id, allVersions)).sum > 0; }
    bool removeOne(string collection, UUID id, bool allVersions = false) {
      Json json = Json.emptyObject;
      json["id"] = id.toString;
      return removeOne(collection, json, allVersions); }
  // #endregion Remove by id 

  // #region Remove by id & versionNumber
    bool removeOne(UUID[] ids, size_t versionNumber) {
      return ids.map!(a => removeOne(a, versionNumber)).sum > 0; }
    bool removeOne(UUID id, size_t versionNumber) {
      return removeOne(collections, id, versionNumber); }

    bool removeOne(string[] areas, string[] pools, UUID[] ids, size_t versionNumber) {
      return areas.map!(a => removeOne(a, pools, ids, versionNumber)).sum > 0; }
    bool removeOne(string[] areas, string pool, UUID[] ids, size_t versionNumber) {
      return areas.map!(a => removeOne(a, pool, ids, versionNumber)).sum > 0; }
    bool removeOne(string area, string[] pools, UUID[] ids, size_t versionNumber) {
      return pools.map!(a => removeOne(area, a, ids, versionNumber)).sum > 0; }
    bool removeOne(string area, string pool, UUID[] ids, size_t versionNumber) {
      return ids.map!(a => removeOne(area, pool, a, versionNumber)).sum > 0; }
    bool removeOne(string collection, UUID[] ids, size_t versionNumber) {
      return ids.map!(a => removeOne(collection, a, versionNumber)).sum > 0; }

    bool removeOne(string[] areas, string[] pools, UUID id, size_t versionNumber) {
      return areas.map!(a => removeOne(a, pools, id, versionNumber)).sum > 0; }
    bool removeOne(string[] areas, string pool, UUID id, size_t versionNumber) {
      return areas.map!(a => removeOne(a, pool, id, versionNumber)).sum > 0; }
    bool removeOne(string area, string[] pools, UUID id, size_t versionNumber) {
      return pools.map!(a => removeOne(area, a, id, versionNumber)).sum > 0; }
    bool removeOne(string area, string pool, UUID id, size_t versionNumber) {
      return removeOne(area ~ separator ~ pool, id, versionNumber); }
    bool removeOne(string[] collections, UUID id, size_t versionNumber) {
      return collections.map!(a => removeOne(a, id, versionNumber)).sum > 0; }
    bool removeOne(string collection, UUID id, size_t versionNumber) {
      Json json = Json.emptyObject;
      json["id"] = id.toString;
      json["versionNumber"] = versionNumber;
      return removeOne(collection, json); }
  // #endregion

  // #region RemoveMany by select (string[string])
    bool removeOne(string[] areas, string[] pools, STRINGAA[] selects, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pools, selects, allVersions)).sum > 0; }
    bool removeOne(string[] areas, string pool, STRINGAA[] selects, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pool, selects, allVersions)).sum > 0; }
    bool removeOne(string area, string[] pools, STRINGAA[] selects, bool allVersions = false) {
      return pools.map!(a => removeOne(area, a, selects, allVersions)).sum > 0; }
    bool removeOne(string area, string pool, STRINGAA[] selects, bool allVersions = false) {
      return selects.map!(a => removeOne(area, pool, a, allVersions)).sum > 0; }
    bool removeOne(string collection, STRINGAA[] selects, bool allVersions = false) {
      return selects.map!(a => removeOne(collection, a, allVersions)).sum > 0; }

    bool removeOne(string[] areas, string[] pools, STRINGAA select, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pools, select, allVersions)).sum > 0; }
    bool removeOne(string[] areas, string pool, STRINGAA select, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pool, select, allVersions)).sum > 0; }
    bool removeOne(string area, string[] pools, STRINGAA select, bool allVersions = false) {
      return pools.map!(a => removeOne(area, a, select, allVersions)).sum > 0; }
    bool removeOne(string area, string pool, STRINGAA select, bool allVersions = false) {
      return removeOne(area ~ separator ~ pool, select, allVersions); }
    bool removeOne(string[] collections, STRINGAA select, bool allVersions = false) {
      return collections.map!(a => removeOne(a, select, allVersions)).sum > 0; }
    bool removeOne(string collection, STRINGAA select, bool allVersions = false) {
      Json json = select.serializeToJson;
      return removeOne(collection, json, allVersions); }
  // #endregion RemoveMany by select (string[string])

  // #region Remove By json
    bool removeOne(string[] areas, string[] pools, Json[] selects, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pools, selects, allVersions)).sum > 0; }
    bool removeOne(string[] areas, string pool, Json[] selects, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pool, selects, allVersions)).sum > 0; }
    bool removeOne(string area, string[] pools, Json[] selects, bool allVersions = false) {
      return pools.map!(a => removeOne(area, a, selects, allVersions)).sum > 0; }
    bool removeOne(string area, string pool, Json[] selects, bool allVersions = false) {
      return selects.map!(a => removeOne(area, pool, a, allVersions)).sum > 0; }
    bool removeOne(string collection, Json[] selects, bool allVersions = false) {
      return selects.map!(a => removeOne(collection, a, allVersions)).sum > 0; }
  // #endregion Remove By json

  // #region Searching based on parameter "select":Json[]
    bool removeOne(string[] areas, string[] pools, Json select, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pools, select, allVersions)).sum > 0; }
    bool removeOne(string[] areas, string pool, Json select, bool allVersions = false) {
      return areas.map!(a => removeOne(a, pool, select, allVersions)).sum > 0; }
    bool removeOne(string area, string[] pools, Json select, bool allVersions = false) {
      return pools.map!(a => removeOne(area, a, select, allVersions)).sum > 0; }
    bool removeOne(string area, string pool, Json select, bool allVersions = false) {
      return removeOne(area ~ separator ~ pool, select, allVersions); }
    bool removeOne(string[] collections, Json select, bool allVersions = false) {
      return collections.map!(a => removeOne(a, select, allVersions)).sum > 0; }
    bool removeOne(string collection, Json select, bool allVersions = false) {
      return false; }
  // #endregion Searching based on parameter "select":Json[]
// #endregion RemoveMany
}