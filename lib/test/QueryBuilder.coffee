'use strict'

QueryBuilder = require '../src/QueryBuilder'
expect = require 'expect.js'

describe 'QueryBuilder.js', ->

    $ = null
    beforeEach ->
        $ = new QueryBuilder()

    describe 'bulkInsert', ->

        it 'should throw an exception if table is not set', ->
            try
                $.bulkInsert(null, 'data')
                expect.fail()
            catch e
                expect(e.name).to.be "Illegal argument"

        it 'should throw an exception if data is not set', ->
            try
                $.bulkInsert('table', null)
                expect.fail()
            catch e
                expect(e.name).to.be "Illegal argument"

        it 'should output INSERT INTO sky (star,planet) VALUES (sun,earth) if the filer fields are set', ->
            data = [
                {
                    star: 'sun'
                    planet: 'earth'
                    sattelite: 'moon'
                }
                {
                    star: 'sun'
                    planet: 'jupiter'
                    sattelite: 'europa'
                }
            ]
            expect($.bulkInsert('sky', data, ['star', 'planet']).build()).to.eql "INSERT INTO sky (star,planet) VALUES ('sun','earth'),('sun','jupiter')"

        it 'should output INSERT INTO sky (star,planet,sattelite) VALUES (sun,earth,moon)... even if no fields are set', ->
            data = [
                {
                    star: 'sun'
                    planet: 'earth'
                    sattelite: 'moon'
                }
                {
                    star: 'sun'
                    planet: 'jupiter'
                    sattelite: 'europa'
                }
            ]
            expect($.bulkInsert('sky', data).build()).to.eql "INSERT INTO sky (star,planet,sattelite) VALUES ('sun','earth','moon'),('sun','jupiter','europa')"

        it 'should output INSERT INTO sky (planet) VALUES (earth)... with the excluding fields option', ->
            data = [
                {
                    star: 'sun'
                    planet: 'earth'
                    sattelite: 'moon'
                }
                {
                    star: 'sun'
                    planet: 'jupiter'
                    sattelite: 'europa'
                }
            ]
            expect($.bulkInsert('sky', data, null, ['sattelite', 'star']).build()).to.eql "INSERT INTO sky (planet) VALUES ('earth'),('jupiter')"

        it 'should output INSERT INTO sky (star,planet) VALUES (sun,earth)... with all options (just in case)', ->
            data = [
                {
                    star: 'sun'
                    planet: 'earth'
                    sattelite: 'moon'
                }
                {
                    star: 'sun'
                    planet: 'jupiter'
                    sattelite: 'europa'
                }
            ]
            expect($.bulkInsert('sky', data, ['planet', 'sattelite'], ['sattelite', 'non-existant']).build()).to.eql "INSERT INTO sky (planet) VALUES ('earth'),('jupiter')"

    describe 'selectStarFrom', ->

        it 'should output SELECT * FROM + table', ->
            expect("SELECT * FROM sky").to.be $.selectStarFrom("sky").build()

        it 'should throw an exception if the parameter table is not passed', ->
            try
                $.selectStarFrom()
                expect.fail()
            catch e
                expect(e.name).to.be "Illegal argument"

    describe 'selectCountStarFrom', ->

        it 'should output SELECT COUNT(*) AS count FROM + table', ->
            expect("SELECT COUNT(*) AS count FROM sky").to.be $.selectCountStarFrom("sky").build()

        it 'should throw an exception if the parameter table is not passed', ->
            expect(->
                $.selectCountStarFrom()
            ).to.throwException((e) ->
                expect(e.name).to.be 'Illegal argument'
            )

    describe 'selectMaxFrom', ->

        it 'should output SELECT MAX(field) FROM table', ->
            expect("SELECT MAX(field) as max FROM table").to.be $.selectMaxFrom("field", 'table').build()

        it 'should throw an exception if the parameter table is not passed', ->
            expect(->
                $.selectMaxFrom()
            ).to.throwException((e) ->
                expect(e.name).to.be 'Illegal argument'
            )

    describe 'select', ->

        it 'should output SELECT + the parameters if they are passed', ->
            expect("SELECT c1, c2, c3").to.be $.select("c1", "c2", "c3").build()

        it 'should throw an exception if the parameter table is not passed', ->
            try
                $.select()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'from', ->

        it 'should output FROM + table if the parameter is passed', ->
            expect("FROM sky").to.be $.from("sky").build()

        it 'should throw an exception if the parameter table is not a string', ->
            try
                $.from 1
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'deleteFrom', ->

        it 'should output DELETE FROM + table if the parameter is passed', ->
            expect("DELETE FROM sky").to.be $.deleteFrom("sky").build()

        it 'should throw an exception if the parameter table is not a string', ->
            try
                $.deleteFrom 1
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'where', ->

        it 'should output a WHERE + conditions separated by ANDs if multiple parameters are passed', ->
            expect("WHERE a > 10 AND b < 10").to.be $.where("a > 10", "b < 10").build()

        it 'should output a WHERE + conditions separated by ANDs if the parameter is an array containing the conditions', ->
            expect("WHERE a > 10 AND b < 10").to.be $.where(["a > 10", "b < 10"]).build()

    describe 'join', ->

        it 'should output a JOIN + table name', ->
            expect("JOIN sky").to.be $.join("sky").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.join()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'innerJoin', ->

        it 'should output an INNER JOIN + table name', ->
            expect("INNER JOIN sky").to.be $.innerJoin("sky").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.innerJoin()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'leftJoin', ->

        it 'should output an LEFT JOIN + table name', ->
            expect("LEFT JOIN sky").to.be $.leftJoin("sky").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.leftJoin()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'rightJoin', ->

        it 'should output an RIGHT JOIN + table name', ->
            expect("RIGHT JOIN sky").to.be $.rightJoin("sky").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.rightJoin()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'on', ->

        it 'should output an ON + conditions', ->
            expect("ON a = b AND c = d").to.be $.on("a = b", "c = d").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.on()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'update', ->

        it 'should output an UPDATE + table name', ->
            expect("UPDATE sky").to.be $.update("sky").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.update()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'set', ->

        it 'should output a SET + fields and values', ->
            expect("SET one = 1, two = 2, three = 'three'").to.be $.set(
                one: $.value(1)
                two: $.value(2)
                three: $.value("three")
            ).build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.set()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'insertInto', ->

        it 'should output an INSERT INTO + table name', ->
            expect("INSERT INTO sky").to.be $.insertInto("sky").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.insertInto()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'orderBy', ->

        it 'should output an order by expression', ->
            expect("ORDER BY id DESC").to.be $.orderBy("id", "DESC").build()

        it 'should throw an exception if no parametes were passed', ->
            try
                $.orderBy()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'groupBy', ->

        it 'should output GROUP BY + fields if they are passed', ->
            expect("GROUP BY c1, c2, c3").to.be $.groupBy("c1", "c2", "c3").build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.groupBy()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'having', ->

        it 'should output HAVING + conditions', ->
            expect("HAVING a > 10 AND b < 10").to.be $.having("a > 10", "b < 10").build()

    describe 'limit', ->

        it 'should output LIMIT + parameters if they are passed', ->
            expect("LIMIT :limit, 1000").to.be $.limit(":limit", 1000).build()

        it 'should output LIMIT + parameter if only one is passed', ->
            expect("LIMIT 1").to.be $.limit(1).build()

        it 'should throw an exception if no parameters are passed', ->
            try
                $.limit()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    # Operations
    describe 'equal', ->

        it 'should output an equals expression', ->
            expect("x = 10").to.be $.equal("x", 10)

        it 'should output an IS NULL if the right parameter is null', ->
            expect("x IS NULL").to.be $.equal("x", null)

        it 'should throw an Illegal argument exception if one of the parameters is undefined', ->
            try
                $.equal()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    # Operations
    describe 'like', ->

        it 'should output a like expression', ->
            expect("x LIKE 10").to.be $.like("x", 10)

        it 'should throw an Illegal argument exception if one of the parameters is undefined', ->
            expect(-> $.like()).to.throwException((e) -> expect(e.name).to.be 'Illegal argument')

    describe 'notEqual', ->

        it 'should output a not equals expression', ->
            expect("x <> 10").to.be $.notEqual("x", 10)

        it 'should output an IS NOT NULL if the right parameter is null', ->
            expect("x IS NOT NULL").to.be $.notEqual("x", null)

        it 'should throw an Illegal argument exception if one of the parameters is undefined', ->
            try
                $.notEqual()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'less', ->

        it 'should output a less expression', ->
            expect("x < 10").to.be $.less("x", 10)

        it 'should throw an exception if one of the parameters is missing', ->
            try
                $.less 1
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'lessOrEqual', ->

        it 'should output a less or equal expression', ->
            expect("x <= 10").to.be $.lessOrEqual("x", 10)

        it 'should throw an exception if one of the parameters is missing', ->
            try
                $.lessOrEqual 1
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'greater', ->

        it 'should output a greater expression', ->
            expect("x > 10").to.be $.greater("x", 10)

        it 'should throw an exception if one of the parameters is missing', ->
            try
                $.greater 1
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'greaterOrEqual', ->

        it 'should output a greater or equal expression', ->
            expect("x >= 10").to.be $.greaterOrEqual("x", 10)

        it 'should throw an exception if one of the parameters is missing', ->
            try
                $.greaterOrEqual 1
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'between', ->

        it 'should output a BETWEEN expression', ->
            expect("b BETWEEN a AND c").to.be $.between("b", "a", "c")

        it 'should throw an exception if one of the parameters is missing', ->
            try
                $.between()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'in', ->

        it 'should output an IN expression', ->
            expect("id IN (1, 2, 3)").to.be $["in"]("id", [
                1
                2
                3
            ])
            expect("id IN ('1', 'a', 3)").to.be $["in"]("id", [
                "1"
                "a"
                3
            ])

        it 'should throw an exception if no parameters were passed', ->
            try
                $["in"]()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

    describe 'as', ->

        it 'should throw an Illegal argument exception if origin or alias are not a string', ->
            try
                $.as()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

        it 'should output an AS expression if arguments are right', ->
            expect("name AS newName").to.be $.as "name", "newName"

    describe 'or', ->

        it 'should throw an Illegal argument exception if less than two parameters are passed', ->
            try
                $.or()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

        it 'should output an OR expression if multiple parameters are passed', ->
            expect("(a OR b OR c)").to.be $.or("a", "b", "c")

        it 'should output an OR expression if a single array is passed', ->
            expect("(a OR b OR c)").to.be $.or(["a", "b", "c"])

    describe 'escape', ->

        it 'should output an quoted string if value is string', ->
            expect("'string'").to.be $.escape "string"

        it 'should output a non-quoted null value if the parameter is null', ->
            expect($.escape(null)).not.to.be.ok()

    describe 'and', ->

        it 'should throw an Illegal argument exception if less than two parameters are passed', ->
            try
                $.and()
                assert.fail()
            catch e
                expect("Illegal argument").to.be e.name

        it 'should output an AND expression if multiple parameters are passed', ->
            expect("(a AND b AND c)").to.be $.and("a", "b", "c")

        it 'should output an AND expression if a single array is passed', ->
            expect("(a AND b AND c)").to.be $.and(["a", "b", "c"])

    describe 'Integration Tests', ->

        it 'should output: SELECT c1, c2, c3 FROM sky WHERE y = :y AND z < :z AND x BETWEEN NOW() AND AAAA AND (y = 10 OR z > 20 OR x BETWEEN 10 AND 200)', ->
            sql = $.select("c1", "c2", "c3")
            .from("sky")
            .where(
                $.equal("y", ":y"),
                $.less("z", ":z"),
                $.between("x", "NOW()", "AAAA"),
                $.or(
                    $.equal("y", $.value(10)),
                    $.greater("z", $.value(20)),
                    $.between("x", $.value(10), $.value(200))
                )
            ).build()
            expected = "SELECT c1, c2, c3 FROM sky WHERE y = :y AND z < :z AND x BETWEEN NOW() AND AAAA AND (y = 10 OR z > 20 OR x BETWEEN 10 AND 200)"
            expect(expected).to.be sql

        it 'should output: SELECT * FROM sky GROUP BY x HAVING z > 10 AND z < 100 LIMIT 100, 1000', ->
            sql = $.selectStarFrom("sky").groupBy("x").having($.greater("z", 10), $.less("z", 100)).limit(100, 1000).build()
            expected = "SELECT * FROM sky GROUP BY x HAVING z > 10 AND z < 100 LIMIT 100, 1000"
            expect(expected).to.be sql

        it 'should output: DELETE FROM sky WHERE x = y', ->
            sql = $.deleteFrom("sky").where($.equal("x", "y")).build()
            expected = "DELETE FROM sky WHERE x = y"
            expect(expected).to.be sql

        it 'should output: UPDATE sky SET one = 1, two = 2', ->
            sql = $.update("sky").set(
                one: 1
                two: 2
            ).where($.or($.greater("id", 0), $.less("id", 1000))).build()
            expected = "UPDATE sky SET one = 1, two = 2 WHERE (id > 0 OR id < 1000)"
            expect(expected).to.be sql

        it "should output: INSERT INTO log SET message = 'This is a message'", ->
            sql = $.insertInto("log").set(message: $.value("This is a message")).build()
            expected = "INSERT INTO log SET message = 'This is a message'"
            expect(expected).to.be sql

        it 'should output: SELECT * FROM sky INNER JOIN heaven ON heaven.jesus = sky.jesus', ->
            sql = $.selectStarFrom("sky").innerJoin("heaven").on($.equal("heaven.jesus", "sky.jesus")).build()
            expected = "SELECT * FROM sky INNER JOIN heaven ON heaven.jesus = sky.jesus"
            expect(expected).to.be sql
