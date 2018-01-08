# SCCMOperationalCollections
This is a remake of another script that will create Operational Collections in SCCM.

The biggest issue with the original script was that it would stop the execution because the collection already existed. This resulted
in having to manually delete every single collection. Since some of the collections reference other collections, you can't just select
all of them and hit delete. This was very time consuming.

I decided to combined the the list of collections with the creating collections in the original script and made it more readable.
Now that everything was combined I looped though each collection and if it exist, nothing happens but the script continues and creates
the collection.

.First time you run this, It will create the folder and create all the collections for you.

.Second time you run this, if all the collections exist, nothing happens. If one is missing or was deleted, it will only create the one.

.Make sure you delete Collection4 or else you will have multiple Not Latest Collections.

.Feel free to remove the pause at the end if you see fit. This is just to confirm what already exist or has been created.
