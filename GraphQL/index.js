import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from '@apollo/server/standalone';
import mongoose from 'mongoose';
const { Schema } = mongoose;
import neo4j from 'neo4j-driver';

const MONGODB_URI = "mongodb+srv://hdi:test@cluster0.bjbokej.mongodb.net";
const NEO4J_URI = "neo4j://localhost:7687";
const driver = neo4j.driver(NEO4J_URI, neo4j.auth.basic('neo4j', 'password'));
const AVG_FUEL_CONSUMPTION_L_KM = 0.02;
/**
 *
 *  Schema & model MongoDb Table
 */
const clientSchema = new Schema({
    client_id: { type: Number, required: true, unique: true },
    name: String,
    affiliation: String,
    contact: String,
    home_port: String //ID neo4j
});

export const Client = mongoose.model('Client', clientSchema, 'clients');

const productSchema = new Schema({
    product_id: { type: Number, required: true, unique: true },
    name: String,
    weight: Number,
    volume: Number,
    stock_total: Number,
    crates_per_unit: Number
});
export const Product = mongoose.model('Product', productSchema, 'products');

const orderItemSchema = new Schema({
    product_id: Number,
    qty: Number
}, { _id: false });

const orderSchema = new Schema({
    order_id: { type: Number, required: true, unique: true },
    client_id: Number,
    items: [orderItemSchema],
    status: String,
    created_at: Date,
    delivered_at: Date,
    assigned_delivery_id: String
});
export const Order = mongoose.model('Order', orderSchema, 'orders');

const lockerSchema = new Schema({
    locker_id: { type: Number, required: true, unique: true },
    port_id: Number,
    is_empty: Boolean,
    occupied_by_order_id: Number
});
export const Locker = mongoose.model('Locker', lockerSchema, 'lockers');

const traceSchema = new Schema({
    hydravion_id: String,
    timestamp: Date,
    lat: Number,
    lon: Number,
    altitude: Number,
    speed: Number,
    fuel_level: Number
});

const HydravionTrace = mongoose.model('HydravionTrace', traceSchema, 'hydravion_traces');

const typeDefs = `
  #Neo4j
  type Point {
    lat: Float
    lon: Float
  }
  
  type Island {
    island_code: String
    name: String
    area_km2: Float
    location: Point
    zones: [Zone]
  }
  
  type Zone {
    zone_code: String
    name: String
    type: String
    location: Point
    island: Island 
    destinations: [Zone] 
  }
  
  type Seaplane {
    id: ID!
    model: String
    status: String
    location: Point
    fuel: Float
    capacity: Int
  }
  
  type SeaplaneStatus {
    id: ID!
    status: String
    location: Point
    fuel_level: Float
    timestamp: String
  }
  
  type RouteSegment {
    from: String
    to: String
    distance_km: Float
  }
  
  type StopInfo {
    zone_code: String
    has_empty_lockers: Boolean
    available_lockers_count: Int
  }
  
  type RoutePlan {
    total_distance_km: Float
    estimated_fuel_needed: Float
    segments: [RouteSegment]
    stops_status: [StopInfo]
    is_feasible: Boolean 
    warning: String   
  }

  #MongoDb
  type Product { 
    name: String,
    weight: Float,
    volume: Float,
    stock_total: Int,
    crates_per_unit: Float
  }
  
  type Client { 
    client_id: Int,
    name: String,
    affiliation: String,
    contact: String,
    home_port: String
  }
  
  type Locker {
    _id: ID!
    locker_id: Int!
    port_id: Int
    is_empty: Boolean
    occupied_by_order_id: Int
  }
  
  type OrderItem {
    product_id: Int,
    qty: Int
  } 
  
  type Order {
    order_id: Int,
    client_id: Int,
    items: [OrderItem],
    status: String,
    created_at: String,
    delivered_at: String,
    assigned_delivery_id: String
  }

  type Query {
    islands: [Island],
    zones(island_code: String): [Zone],
    seaplanes(status: String): [Seaplane],
    products: [Product],
    clients: [Client],
    lockers(port_id: Int, is_empty: Boolean): [Locker],
    orders(client_id: Int): [Order],
    locateSeaplanes(atTime: String): [SeaplaneStatus],
    optimizeDelivery(
        seaplaneId: String!, 
        warehouseZoneCode: String!, 
        clientIds: [Int]! 
    ): RoutePlan
  }
`;

const resolvers = {
    Query: {
        /**
         * Neo4j Queries
         * Get All Islands
         */
        islands: async () => {
            const session = driver.session();
            try {
                const res = await session.run('MATCH (n:Island) RETURN n');
                return res.records.map(record => {
                    const props = record.get('n').properties;
                    return {
                        ...props,
                        location: formatPoint(props.location)
                    };
                });
            } finally {
                await session.close();
            }
        },

        /**
         * Get All Or Specific Zone
         */
        zones: async (_, { island_code }) => {
            const session = driver.session();
            try {
                let query = 'MATCH (z:HydroplaneZone) RETURN z';
                let params = {};

                if (island_code) {
                    query = 'MATCH (i:Island {island_code: $code})-[:HAS_ZONE]->(z:HydroplaneZone) RETURN z';
                    params = { code: island_code };
                }

                const res = await session.run(query, params);
                return res.records.map(record => {
                    const props = record.get('z').properties;
                    return {
                        ...props,
                        location: formatPoint(props.location)
                    };
                });
            } finally {
                await session.close();
            }
        },

        /**
         * MongoDb Queries
         * Get Lockers of port & empty or not
         */
        lockers: async (_, { port_id, is_empty }) => {
            const query = {};

            if (port_id !== undefined) {
                query.port_id = port_id;
            }

            if (is_empty !== undefined) {
                query.is_empty = is_empty;
            }

            return await Locker.find(query);
        },

        /**
         * Get All Orders From Client by id
         */
        orders: async (_, { client_id }) => {
            const query = {};

            if (client_id !== undefined) {
                query.client_id = client_id;
            }

            return await Order.find(query);
        },

        /**
         * Get all Products
         */
        products: async () => {
            try {
                return await Product.find();
            } catch (error) {
                console.error("Erreur Mongo:", error);
                return [];
            }
        },

        /**
         * Get All Clients
         */
        clients: async () => {
            try {
                return await Client.find();
            } catch (error) {
                console.error("Erreur Mongo:", error);
                return [];
            }
        },

        /**
         * Get current position of seaplane or at one time
         */
        locateSeaplanes: async (_, { atTime }) => {
            if (atTime) {
                const targetDate = new Date(atTime);
                const traces = await HydravionTrace.aggregate([
                    { $match: { timestamp: { $lte: targetDate } } },
                    { $sort: { timestamp: -1 } },
                    { $group: {
                            _id: "$hydravion_id",
                            doc: { $first: "$$ROOT" }
                        }
                    }
                ]);

                return traces.map(t => ({
                    id: t._id,
                    status: t.doc.speed > 0 ? "IN_FLIGHT" : "DOCKED",
                    lat: t.doc.lat,
                    lon: t.doc.lon,
                    fuel_level: t.doc.fuel_level,
                    timestamp: t.doc.timestamp.toISOString()
                }));
            }

            else {
                const session = driver.session();
                try {
                    const res = await session.run(`
            MATCH (s:Seaplane)
            RETURN s
          `);

                    return res.records.map(r => {
                        const props = r.get('s').properties;
                        return {
                            id: props.id,
                            status: props.status,
                            fuel_level: props.fuel,
                            location: formatPoint(props.location),
                            timestamp: new Date().toISOString()
                        };
                    });
                } finally {
                    await session.close();
                }
            }
        },

        optimizeDelivery: async (_, { seaplaneId, warehouseZoneCode, clientIds }) => {
            const session = driver.session();

            try {
                const clients = await Client.find({ client_id: { $in: clientIds } });
                const portRefs = [...new Set(clients.map(c => c.home_port))];

                const idPorts = portRefs.filter(p => !p.startsWith("ZONE"));
                const zonePorts = portRefs.filter(p => p.startsWith("ZONE"));
                let convertedPorts = [];

                if (idPorts.length > 0) {
                    const res = await session.run(
                        `
                MATCH (z:HydroplaneZone)
                WHERE elementId(z) IN $ids
                RETURN elementId(z) AS id, z.zone_code AS code
                `,
                        { ids: idPorts }
                    );

                    const mapRes = Object.fromEntries(res.records.map(r => [
                        r.get("id"),
                        r.get("code")
                    ]));

                    convertedPorts = idPorts
                        .map(id => mapRes[id])
                        .filter(code => code);
                }

                const targetZoneCodes = [...zonePorts, ...convertedPorts];

                if (targetZoneCodes.length === 0 && clientIds.length > 0) {
                    throw new Error("Aucun port valide trouvé pour les clients sélectionnés.");
                }
                const orders = await Order.find({
                    client_id: { $in: clientIds },
                    status: "pending"
                });

                const products = await Product.find();
                const cratesMap = {};
                for (const p of products) cratesMap[p.product_id] = p.crates_per_unit || 1;

                const cratesPerZone = {};
                let totalCratesNeeded = 0;

                for (const order of orders) {
                    const client = clients.find(c => c.client_id === order.client_id);
                    const zone = client.home_port.startsWith("ZONE")
                        ? client.home_port
                        : convertedPorts[portRefs.indexOf(client.home_port)];

                    if (!zone) continue;

                    for (const item of order.items) {
                        const crates = (cratesMap[item.product_id] || 1) * item.qty;
                        cratesPerZone[zone] = (cratesPerZone[zone] || 0) + crates;
                        totalCratesNeeded += crates;
                    }
                }
                const planeRes = await session.run(`
            MATCH (s:Seaplane {id: $id})
            RETURN s, s.location AS location
        `, { id: seaplaneId });

                if (planeRes.records.length === 0)
                    throw new Error(`Avion ${seaplaneId} inconnu`);

                const planeNode = planeRes.records[0].get("s").properties;
                const planeLocation = planeRes.records[0].get("location");
                const planeCapacity = neo4j.isInt(planeNode.capacity)
                    ? planeNode.capacity.toNumber()
                    : planeNode.capacity;

                const itinerary = [
                    { type: "point", ref: planeLocation },
                    { type: "zone", ref: warehouseZoneCode },
                    ...targetZoneCodes.map(z => ({ type: "zone", ref: z })),
                    { type: "zone", ref: warehouseZoneCode },
                    { type: "point", ref: planeLocation }
                ];

                const segments = [];
                for (let i = 0; i < itinerary.length - 1; i++) {
                    segments.push({
                        start: itinerary[i],
                        end: itinerary[i + 1]
                    });
                }

                const zonePairs = segments
                    .map((s, i) => ({
                        i,
                        start: s.start.type === "zone" ? s.start.ref : null,
                        end: s.end.type === "zone" ? s.end.ref : null,
                    }))
                    .filter(s => s.start && s.end);

                let zoneDistances = {};
                if (zonePairs.length > 0) {
                    const res = await session.run(`
                UNWIND $pairs AS p
                MATCH (a:HydroplaneZone {zone_code: p.start})
                MATCH (b:HydroplaneZone {zone_code: p.end})
                RETURN p.i AS idx,
                       point.distance(a.location, b.location)/1000 AS dist
            `, { pairs: zonePairs });

                    zoneDistances = Object.fromEntries(
                        res.records.map(r => [
                            r.get("idx"),
                            r.get("dist")
                        ])
                    );
                }


                let totalDistance = 0;
                const finalSegments = [];

                for (let i = 0; i < segments.length; i++) {
                    const seg = segments[i];
                    let dist = 0;

                    if (seg.start.type === "zone" && seg.end.type === "zone") {
                        dist = zoneDistances[i] || 0;
                    } else {
                        // POINT -> ZONE ou ZONE -> POINT
                        const isStartPoint = seg.start.type === "point";
                        const point = isStartPoint ? seg.start.ref : seg.end.ref;
                        const zone = isStartPoint ? seg.end.ref : seg.start.ref;

                        const res = await session.run(`
                    MATCH (z:HydroplaneZone {zone_code: $zone})
                    RETURN point.distance($pt, z.location)/1000 AS dist
                `, { pt: point, zone });

                        dist = res.records[0].get("dist") || 0;
                    }

                    totalDistance += dist;
                    finalSegments.push({
                        from: seg.start.ref,
                        to: seg.end.ref,
                        distance_km: Math.round(dist * 100) / 100
                    });
                }

                const availableLockers = await Locker.countDocuments({ is_empty: true });
                const lockerWarning = availableLockers < totalCratesNeeded
                    ? "ATTENTION : Capacité lockers insuffisante. Livraison partielle requise."
                    : null;


                const fuelNeeded = totalDistance * AVG_FUEL_CONSUMPTION_L_KM;
                const isFeasible =
                    fuelNeeded <= planeNode.fuel &&
                    totalCratesNeeded <= planeCapacity;

                const stopsStatus = targetZoneCodes.map(z => ({
                    zone_code: z,
                    crates_to_deliver: cratesPerZone[z] || 0,
                    has_empty_lockers: availableLockers > 0,
                    available_lockers_count: availableLockers
                }));

                return {
                    total_distance_km: Math.round(totalDistance * 100) / 100,
                    estimated_fuel_needed: Math.round(fuelNeeded * 100) / 100,
                    is_feasible: isFeasible,
                    segments: finalSegments,
                    stops_status: stopsStatus,
                    warning: lockerWarning
                };

            } catch (err) {
                console.error("Erreur optimisation:", err);
                throw err;
            } finally {
                await session.close();
            }
        },

    },
};

const startServer = async () => {
    await mongoose.connect(MONGODB_URI);

    const server = new ApolloServer({ typeDefs, resolvers });
    const { url } = await startStandaloneServer(server, { listen: { port: 4000 } });
    console.log(url);
};

function formatPoint (neo4jPoint) {
    if (!neo4jPoint) return null;

    return { lon: neo4jPoint.x, lat: neo4jPoint.y };
}

startServer();