--Pissaze Database Final Project--

CREATE DATABASE pissaze;

\c pissaze_system

CREATE TYPE transaction_enum AS ENUM ('successful', 'semi-successful', 'unsuccessful');
CREATE TYPE discount_enum AS ENUM ('public', 'private');
CREATE TYPE cart_status_enum AS ENUM ('locked', 'registered', 'blocked');
CREATE TYPE cooling_method_enum AS ENUM ('liquid', 'air');