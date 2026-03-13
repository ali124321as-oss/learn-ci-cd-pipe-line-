import * as dotenv from 'dotenv';
import { DataSource } from 'typeorm';

dotenv.config();

export const AppDataSource = new DataSource({
    type: 'postgres',
    host: process.env.DATABASE_HOST,
    port: parseInt(process.env.DATABASE_PORT || "5433"),
    username: process.env.POSTGRES_USER,
    password: process.env.POSTGRES_PASSWORD,
    database: process.env.POSTGRES_DB,
    migrationsTransactionMode: 'each',
    entities: [__dirname + '../../../**/*.entity.{js,ts}'],
    migrations: ['dist/src/migrations/*.js'],
    synchronize: false,
    name: 'default',
});
