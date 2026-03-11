#ifndef __3DFIER__Definitions__
#define __3DFIER__Definitions__

#include <iostream>
#include <fstream>
#include <cmath>
#include <cstdint>
#include <vector>
#include <unordered_map>

#include <lasreader.hpp>
#include <ogrsf_frmts.h>

#include <boost/geometry.hpp>
#include <boost/geometry/geometries/point_xy.hpp>
#include <boost/geometry/geometries/box.hpp>
#include <boost/geometry/geometries/polygon.hpp>
#include <boost/geometry/index/rtree.hpp>

namespace bg = boost::geometry;
namespace bgi = boost::geometry::index;
typedef bg::model::d2::point_xy<double> Point2;
typedef bg::model::segment<Point2> Segment2;
typedef bg::model::polygon<Point2, true, false> Polygon2; //-- cw, first!=last
typedef bg::model::ring<Point2, true, false> Ring2; //-- cw, first!=last
typedef bg::model::box<Point2> Box2;
typedef bg::model::point<double, 3, bg::cs::cartesian> Point3;

struct Point2Key {
  std::int64_t x;
  std::int64_t y;

  bool operator==(const Point2Key& other) const {
    return x == other.x && y == other.y;
  }
};

struct Point2KeyHash {
  std::size_t operator()(const Point2Key& key) const {
    std::size_t h1 = std::hash<std::int64_t>{}(key.x);
    std::size_t h2 = std::hash<std::int64_t>{}(key.y);
    return h1 ^ (h2 << 1);
  }
};

inline Point2Key make_point2_key(const Point2& p) {
  return Point2Key{
    static_cast<std::int64_t>(std::llround(p.x() * 1000.0)),
    static_cast<std::int64_t>(std::llround(p.y() * 1000.0))
  };
}

typedef std::unordered_map< Point2Key, std::vector<int>, Point2KeyHash > NodeColumn;
typedef std::unordered_map< std::string, std::pair<OGRFieldType, std::string> > AttributeMap;

const double TOPODIST = 0.001;
const double SQTOPODIST = TOPODIST * TOPODIST;

typedef struct Triangle {
  int v0;
  int v1;
  int v2;
} Triangle;

typedef struct PolygonFile {
  std::string filename;
  std::string idfield;
  std::string heightfield;
  bool handle_multiple_heights;
  std::vector< std::pair<std::string, std::string> > layers;
} PolygonFile;

typedef struct PointFile {
  std::string filename;
  std::vector<int> lasomits;
  int thinning = 1;
} PointFile;

typedef enum {
   BUILDING        = 0,
   WATER           = 1,
   BRIDGE          = 2,
   ROAD            = 3,
   TERRAIN         = 4,
   FOREST          = 5,
   SEPARATION      = 6
} TopoClass;

typedef enum {
   LAS_BUILDING_ROOF      = 0,
   LAS_BUILDING_GROUND    = 1,
   LAS_WATER              = 2,
   LAS_BRIDGE             = 3,
   LAS_ROAD               = 4,
   LAS_TERRAIN            = 5,
   LAS_FOREST             = 6,
   LAS_SEPARATION         = 7,
   NUM_ALLOWEDLASTOPO     = 8
} AllowedLASTopo;

static bool abs_compare(double a, double b) {
  return (std::abs(a) < std::abs(b));
}
#endif
