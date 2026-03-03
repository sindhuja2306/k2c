🥭 PRODUCT REQUIREMENT DOCUMENT (PRD)
1️⃣ Product Title

MangoMart – Customer Friendly Mango Booking Dashboard

2️⃣ Product Overview

MangoMart is a mobile e-commerce application built using Flutter that allows customers to browse different types of mangos, add them to a cart, and book orders. The order details are sent directly to the admin dashboard for processing.

The system includes:

Customer Dashboard

Cart & Booking System

Admin Order Management Panel

3️⃣ Problem Statement

Currently, small-scale mango sellers and farms lack a structured digital platform to:

Display mango varieties professionally

Allow customers to place bookings easily

Manage orders efficiently

This results in:

Manual order handling

Confusion in stock management

Poor customer experience

4️⃣ Solution

Build a Flutter-based e-commerce application where:

Customers can view all mango varieties

Add mangos to cart

Place bookings

Admin receives order details instantly

5️⃣ Target Users
🎯 Customers

Mango buyers

Bulk buyers

Retail customers

🎯 Admin

Mango seller

Farm owner

Inventory manager

6️⃣ Core Features
🟢 Customer Features
1. Authentication

Login

Register

Logout

2. Mango Dashboard

Display all mango varieties

Show:

Image

Name

Price per kg

Description

Available stock

3. Mango Details Page

Detailed description

Quantity selector

Add to Cart button

4. Cart System

View added items

Update quantity

Remove items

Show total price

5. Checkout & Booking

Enter delivery details

Confirm order

Save order to database

6. Order History

View previous bookings

Order status (Pending / Approved / Delivered)

🔴 Admin Features
1. Admin Dashboard

View total orders

View total revenue

View total customers

2. Manage Mangos

Add new mango

Update price

Update stock

Delete mango

3. Order Management

View customer details

View ordered items

Update order status

Approve / Reject order

7️⃣ Functional Requirements
ID	Requirement
FR1	User must be able to register and login
FR2	System must display all available mangos
FR3	User must be able to add mango to cart
FR4	System must calculate total price automatically
FR5	User must be able to place booking
FR6	Admin must receive booking details
FR7	Admin must be able to update order status
FR8	Only admin can manage mango inventory
8️⃣ Non-Functional Requirements

Responsive UI

Secure authentication

Fast loading (<2 seconds)

Scalable backend

User-friendly interface

9️⃣ Technical Stack
Layer	Technology
Frontend	Flutter
Backend	Firebase / Node.js
Database	Firestore / MongoDB
State Management	Provider / Riverpod
Authentication	Firebase Auth
🔟 Database Structure (High Level)
Users Collection
userId
name
email
role (customer/admin)
Mangos Collection
mangoId
name
price
description
imageUrl
stock
Orders Collection
orderId
userId
items[]
totalAmount
status
deliveryAddress
createdAt
1️⃣1️⃣ User Flow

Customer Flow:

Register → Login → Browse Mangos → Add to Cart → Checkout → Booking Confirmed

Admin Flow:

Login → View Orders → Update Status → Manage Inventory

1️⃣2️⃣ Success Metrics

Number of bookings per day

User retention rate

Average order value

Admin order processing time

1️⃣3️⃣ Future Enhancements

Online payment integration

Push notifications

Mango seasonal discounts

Delivery tracking

Rating & review system

1️⃣4️⃣ MVP Scope (Minimum Version)

For first release:

✅ Authentication
✅ Mango listing
✅ Add to cart
✅ Booking
✅ Admin order view



🎯 Final Vision

A complete K2C marketplace platform that supports small-scale mango sellers and provides a smooth booking experience for customers.