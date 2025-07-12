from flask import render_template, request, redirect, url_for, session, flash, jsonify
from werkzeug.security import check_password_hash
from __init__ import app, db
from models import User, Product

@app.route('/')
def home():
    if 'user_id' in session:
        return redirect(url_for('inventory'))
    return redirect(url_for('login'))

@app.route('/health')
def health():
    import socket
    hostname = socket.gethostname()
    return f"✅ Instancia: {hostname} - Aplicación funcionando correctamente"

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()
        if user and check_password_hash(user.password, password):
            session['user_id'] = user.id
            return redirect(url_for('inventory'))
        else:
            flash('Usuario o contraseña incorrectos')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    return redirect(url_for('login'))

@app.route('/register_product', methods=['GET', 'POST'])
def register_product():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    if request.method == 'POST':
        code = request.form['code']
        if Product.query.filter_by(code=code).first():
            flash('El código de producto ya existe')
            return redirect(url_for('register_product'))
        name = request.form['name']
        description = request.form['description']
        unit = request.form['unit']
        category = request.form['category']
        product = Product(name=name, code=code, description=description, unit=unit, category=category)
        db.session.add(product)
        db.session.commit()
        flash('Producto registrado exitosamente')
        return redirect(url_for('inventory'))
    return render_template('register_product.html')

@app.route('/inventory')
def inventory():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    # Obtener parámetros de búsqueda
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    
    # Construir consulta base
    query = Product.query
    
    # Aplicar filtros
    if search:
        query = query.filter(
            db.or_(
                Product.name.contains(search),
                Product.code.contains(search),
                Product.description.contains(search)
            )
        )
    
    if category:
        query = query.filter(Product.category == category)
    
    # Obtener productos filtrados
    products = query.all()
    
    # Obtener categorías únicas para el filtro
    categories = db.session.query(Product.category).distinct().filter(Product.category.isnot(None)).all()
    categories = [cat[0] for cat in categories]
    
    return render_template('inventory.html', products=products, categories=categories)

@app.route('/api/products')
def api_products():
    products = Product.query.all()
    return jsonify([{
        'id': p.id,
        'name': p.name,
        'code': p.code,
        'description': p.description,
        'unit': p.unit,
        'category': p.category
    } for p in products])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 