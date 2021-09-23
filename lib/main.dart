import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

void main() => runApp(BattleshipApp());

class BattleshipApp extends StatelessWidget {
  final int rows, columns, waves;
  late final List<Ship> ships;

  BattleshipApp({this.columns = 10, this.rows = 10, this.waves = 2}) {
    ships = [
      const Ship(4, 1),
      const Ship(3, 2),
      const Ship(2, 3),
      const Ship(1, 4)
    ];
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('BattleshipPuzzle'),
          ),
          body: _BattleshipHome(rows, columns, ships, waves),
        ),
      );
}

class _BattleshipHome extends StatefulWidget {
  final int _rows, _columns, _waves;
  final List<Ship> _ships;

  const _BattleshipHome(this._rows, this._columns, this._ships, this._waves);

  @override
  _BattleshipHomeState createState() =>
      _BattleshipHomeState(_columns, _rows, _ships, _waves);
}

class _BattleshipHomeState extends State<_BattleshipHome> {
  final int _rows, _columns, _waves;
  final List<Ship> _ships;
  var _tapCount = 0;
  late int _remainCount;
  late List<List<CellType>> _cellTypes;
  late List<List<bool>> _tapped;
  late Size _screenSize;
  late Orientation _orientation;
  static const _cellSizeMax = 40.0;
  late double _cellSize;

  _BattleshipHomeState(this._rows, this._columns, this._ships, this._waves);

  @override
  void initState() {
    super.initState();
    _remainCount = _ships
        .map((e) => e.size * e.num)
        .reduce((value, element) => value + element);
    _cellTypes = _CellTypeGenerator(_rows, _columns, _ships, _waves).generate();
    _tapped =
        List.generate(_rows, (_) => List.generate(_columns, (_) => false));
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    _orientation = MediaQuery.of(context).orientation;
    switch (_orientation) {
      case Orientation.landscape:
        _cellSize = [
          _screenSize.width / 18,
          _screenSize.height / 13,
          _cellSizeMax
        ].reduce(min);
        break;
      case Orientation.portrait:
        _cellSize = [
          _screenSize.width / 12,
          _screenSize.height / 19,
          _cellSizeMax
        ].reduce(min);
        break;
    }

    return _buildContainer();
  }

  Widget _buildContainer() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: _cellSizeMax / 2),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () => _pushReset(),
              child: const Text('Reset'),
            ),
            const SizedBox(width: _cellSizeMax / 2),
            Text('Tap: $_tapCount'),
            const SizedBox(width: _cellSizeMax / 2),
            Text('Remain: $_remainCount'),
          ]),
          const SizedBox(height: _cellSizeMax / 2),
          _buildMainContainer(),
        ],
      );

  Widget _buildMainContainer() {
    switch (_orientation) {
      case Orientation.landscape:
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildArea(),
          _buildBottom(),
        ]);
      case Orientation.portrait:
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _buildArea(),
          _buildBottom(),
        ]);
    }
  }

  Widget _buildArea() => SizedBox(
        width: _cellSize * 11,
        height: _cellSize * 11,
        child: Stack(
          children: [
            _buildColumn(),
            Center(
              child: Container(
                child: _buildClearText(),
              ),
            ),
          ],
        ),
      );

  Widget? _buildClearText() {
    if (_remainCount == 0) {
      return const Text(
        "Clear!!",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 60.0,
          color: Colors.pink,
        ),
      );
    } else {
      return null;
    }
  }

  Widget _buildColumn() {
    final columns = Column(
      children: List.generate(
        _rows,
        (index) => _buildRow(index),
      ),
    );

    columns.children.add(Row(
        children: List.generate(_columns, (cellIndex) {
      List<CellType> _cellTypesOfCell =
          List.generate(_rows, (rowIndex) => _cellTypes[rowIndex][cellIndex]);
      return _buildShipCount(_cellTypesOfCell);
    })));

    return columns;
  }

  Widget _buildRow(int rowIndex) {
    final rows = Row(
      children: List.generate(_columns, (index) => _buildCell(rowIndex, index)),
    );
    rows.children.add(_buildShipCount(_cellTypes[rowIndex]));
    return rows;
  }

  Widget _buildCell(int rowIndex, int columnIndex) {
    final cellType = _cellTypes[rowIndex][columnIndex];
    final alreadyTapped = _tapped[rowIndex][columnIndex];

    final cell = GestureDetector(
      onTap: () => setState(() {
        if (cellType == CellType.Wave) {
          return;
        } else if (alreadyTapped) {
          return;
        } else {
          _tapCount++;
          _tapped[rowIndex][columnIndex] = true;
          if (cellType != CellType.None) {
            _remainCount--;
          }
        }
      }),
      child: Container(
        width: _cellSize,
        height: _cellSize,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
        ),
        child: _buildCellContent(cellType, alreadyTapped),
      ),
    );
    return cell;
  }

  Widget _buildCellContent(CellType cellType, bool alreadyTapped) {
    if (alreadyTapped) {
      switch (cellType) {
        case CellType.Wave:
          return const Icon(Icons.waves);
        case CellType.None:
          return const Icon(Icons.check);
        case CellType.ShipCircle:
          return _buildShipCircle();
        case CellType.ShipSquare:
          return _buildShipSquare();
        case CellType.ShipRoundTop:
          return _buildShipRoundTop();
        case CellType.ShipRoundLeft:
          return _buildShipRoundLeft();
        case CellType.ShipRoundBottom:
          return _buildShipRoundBottom();
        case CellType.ShipRoundRight:
          return _buildShipRoundRight();
        default:
          return Container();
      }
    } else {
      switch (cellType) {
        case CellType.Wave:
          return const Icon(Icons.waves);
        default:
          return Container();
      }
    }
  }

  Widget _buildShipCircle() => Container(
        margin: EdgeInsets.all(_cellSize / 4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
      );

  Widget _buildShipSquare() => Container(
        margin: EdgeInsets.all(_cellSize / 4),
        decoration: const BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.black,
        ),
      );

  Widget _buildShipRoundTop() => Container(
        margin: EdgeInsets.all(_cellSize / 4),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_cellSizeMax / 2),
            topRight: Radius.circular(_cellSizeMax / 2),
          ),
          color: Colors.black,
        ),
      );

  Widget _buildShipRoundLeft() => Container(
        margin: EdgeInsets.all(_cellSize / 4),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(_cellSizeMax / 2),
            bottomLeft: Radius.circular(_cellSizeMax / 2),
          ),
          color: Colors.black,
        ),
      );

  Widget _buildShipRoundBottom() => Container(
        margin: EdgeInsets.all(_cellSize / 4),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(_cellSizeMax / 2),
            bottomRight: Radius.circular(_cellSizeMax / 2),
          ),
          color: Colors.black,
        ),
      );

  Widget _buildShipRoundRight() => Container(
        margin: EdgeInsets.all(_cellSize / 4),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(_cellSizeMax / 2),
            bottomRight: Radius.circular(_cellSizeMax / 2),
          ),
          color: Colors.black,
        ),
      );

  Widget _buildShipCount(List<CellType> cellTypes) {
    final shipCount = cellTypes.where((cellType) {
      switch (cellType) {
        case CellType.ShipCircle:
        case CellType.ShipSquare:
        case CellType.ShipRoundTop:
        case CellType.ShipRoundLeft:
        case CellType.ShipRoundBottom:
        case CellType.ShipRoundRight:
          return true;
        default:
          return false;
      }
    }).length;

    return SizedBox(
      width: _cellSize,
      height: _cellSize,
      child: Center(
          child:
              Text(shipCount.toString(), style: const TextStyle(fontSize: 18))),
    );
  }

  Widget _buildBottom() {
    final column = Column(
        children: List.generate(
            _ships.length, (index) => _buildShips(_ships[index])));
    return SizedBox(
      width: _cellSize * 6,
      height: _cellSize * 4,
      child: column,
    );
  }

  Widget _buildShips(Ship ship) {
    return Row(
      children: List.generate(ship.num, (index) => _buildShip(ship.size)),
    );
  }

  Widget _buildShip(int size) {
    if (size == 1) {
      return SizedBox(
        width: _cellSize,
        height: _cellSize,
        child: _buildShipCircle(),
      );
    } else {
      List<Widget> row = [];
      row.add(
        SizedBox(
          width: _cellSize,
          height: _cellSize,
          child: _buildShipRoundLeft(),
        ),
      );
      for (var sizeIndex = 2; sizeIndex < size; sizeIndex++) {
        row.add(
          SizedBox(
            width: _cellSize,
            height: _cellSize,
            child: _buildShipSquare(),
          ),
        );
      }
      row.add(
        SizedBox(
          width: _cellSize,
          height: _cellSize,
          child: _buildShipRoundRight(),
        ),
      );
      return SizedBox(
        width: size * _cellSize,
        height: _cellSize,
        child: Row(children: row),
      );
    }
  }

  void _pushReset() {
    setState(() {
      _tapCount = 0;
      _remainCount = _ships
          .map((e) => e.size * e.num)
          .reduce((value, element) => value + element);
      _cellTypes =
          _CellTypeGenerator(_rows, _columns, _ships, _waves).generate();
      for (var i = 0; i < _rows; i++) {
        for (var j = 0; j < _columns; j++) {
          _tapped[i][j] = false;
        }
      }
    });
  }
}

class _CellTypeGenerator {
  final int _rows, _columns, _waves;
  final List<Ship> _ships;

  _CellTypeGenerator(this._rows, this._columns, this._ships, this._waves);

  List<List<CellType>> generate() {
    var cellTypes = List.generate(
        _rows, (_) => List.generate(_columns, (_) => CellType.None));

    for (var ship in _ships) {
      cellTypes = placeShip(cellTypes, ship);
    }
    cellTypes = placeWave(cellTypes);

    return cellTypes;
  }

  List<List<CellType>> placeShip(List<List<CellType>> cellTypes, Ship ship) {
    for (var numIndex = 0; numIndex < ship.num; numIndex++) {
      var positions = buildPositions(cellTypes, ship);
      if (positions.isEmpty) {
        continue;
      }
      var position = positions[Random().nextInt(positions.length)];
      if (ship.size == 1) {
        cellTypes[position.item2][position.item3] = CellType.ShipCircle;
      } else if (position.item1 == Direction.Horizontal) {
        cellTypes[position.item2][position.item3] = CellType.ShipRoundLeft;
        for (var sizeIndex = 1; sizeIndex < ship.size; sizeIndex++) {
          cellTypes[position.item2][position.item3 + sizeIndex] =
              CellType.ShipSquare;
        }
        cellTypes[position.item2][position.item3 + ship.size - 1] =
            CellType.ShipRoundRight;
      } else {
        cellTypes[position.item2][position.item3] = CellType.ShipRoundTop;
        for (var sizeIndex = 1; sizeIndex < ship.size; sizeIndex++) {
          cellTypes[position.item2 + sizeIndex][position.item3] =
              CellType.ShipSquare;
        }
        cellTypes[position.item2 + ship.size - 1][position.item3] =
            CellType.ShipRoundBottom;
      }
    }
    return cellTypes;
  }

  List<List<CellType>> placeWave(List<List<CellType>> cellTypes) {
    for (var i = 0; i < _waves; i++) {
      List<Tuple2<int, int>> positions = [];
      for (var row = 0; row < _rows; row++) {
        for (var column = 0; column < _columns; column++) {
          if (cellTypes[row][column] == CellType.None) {
            positions.add(Tuple2(row, column));
          }
        }
      }
      var position = positions[Random().nextInt(positions.length)];
      cellTypes[position.item1][position.item2] = CellType.Wave;
    }
    return cellTypes;
  }

  List<Tuple3<Direction, int, int>> buildPositions(
      List<List<CellType>> cellTypes, Ship ship) {
    List<Tuple3<Direction, int, int>> positions = [];
    for (var row = 0; row < _rows; row++) {
      for (var column = 0; column < _columns; column++) {
        if (canExistsHorizontal(cellTypes, ship, row, column)) {
          positions.add(Tuple3(Direction.Horizontal, row, column));
        }
        if (canExistsVertical(cellTypes, ship, row, column)) {
          positions.add(Tuple3(Direction.Vertical, row, column));
        }
      }
    }
    return positions;
  }

  bool canExistsHorizontal(
      List<List<CellType>> cellTypes, Ship ship, int row, int column) {
    if (_columns < column + ship.size) {
      return false;
    }
    // 上下チェック
    for (var i = column - 1; i <= column + ship.size; i++) {
      if (i < 0 || _columns <= i) {
        continue;
      }
      if (0 < row && cellTypes[row - 1][i] != CellType.None) {
        return false;
      }
      if (cellTypes[row][i] != CellType.None) {
        return false;
      }
      if (row + 1 < _rows && cellTypes[row + 1][i] != CellType.None) {
        return false;
      }
    }
    return true;
  }

  bool canExistsVertical(
      List<List<CellType>> cellTypes, Ship ship, int row, int column) {
    if (_rows < row + ship.size) {
      return false;
    }
    // 左右チェック
    for (var i = row - 1; i <= row + ship.size; i++) {
      if (i < 0 || _rows <= i) {
        continue;
      }
      if (0 < column && cellTypes[i][column - 1] != CellType.None) {
        return false;
      }
      if (cellTypes[i][column] != CellType.None) {
        return false;
      }
      if (column + 1 < _columns && cellTypes[i][column + 1] != CellType.None) {
        return false;
      }
    }
    return true;
  }
}

class Ship {
  final int size, num;

  const Ship(this.size, this.num);
}

enum CellType {
  Wave,
  None,
  ShipCircle,
  ShipSquare,
  ShipRoundTop,
  ShipRoundLeft,
  ShipRoundBottom,
  ShipRoundRight,
}

enum Direction {
  Vertical,
  Horizontal,
}
