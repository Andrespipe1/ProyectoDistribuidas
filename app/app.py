from flask import render_template, request, redirect, url_for, session, flash, jsonify, send_file
from werkzeug.security import check_password_hash
from __init__ import app, db
from models import User, Product
from sqlalchemy import or_
import io
import pandas as pd

CATEGORIES = [
    'Electrónicos', 'Ropa', 'Alimentos', 'Hogar', 'Deportes', 'Libros', 'Otros'
]

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
            flash('El código de producto ya existe', 'danger')
            return redirect(url_for('register_product'))
        name = request.form['name']
        description = request.form['description']
        try:
            unit = int(request.form['unit'])
            if unit < 0:
                raise ValueError
        except ValueError:
            flash('La cantidad debe ser un número entero mayor o igual a 0', 'danger')
            return redirect(url_for('register_product'))
        category = request.form['category']
        if category == 'Otra...':
            category = request.form.get('other_category', '')
        product = Product(name=name, code=code, description=description, unit=unit, category=category)
        db.session.add(product)
        db.session.commit()
        flash('Producto registrado exitosamente', 'success')
        return redirect(url_for('inventory'))
    return render_template('register_product.html', categories=CATEGORIES)

@app.route('/edit_product/<int:product_id>', methods=['GET', 'POST'])
def edit_product(product_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
    product = Product.query.get_or_404(product_id)
    if request.method == 'POST':
        try:
            unit = int(request.form['unit'])
            if unit < 0:
                raise ValueError
        except ValueError:
            flash('La cantidad debe ser un número entero mayor o igual a 0', 'danger')
            return redirect(url_for('edit_product', product_id=product_id))
        product.unit = unit
        db.session.commit()
        flash('Cantidad actualizada exitosamente', 'success')
        return redirect(url_for('inventory'))
    return render_template('edit_product.html', product=product)

@app.route('/inventory')
def inventory():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    estado = request.args.get('estado', '')
    query = Product.query
    if search:
        query = query.filter(
            or_(
                Product.name.contains(search),
                Product.code.contains(search),
                Product.description.contains(search)
            )
        )
    if category:
        query = query.filter(Product.category == category)
    if estado == 'disponible':
        query = query.filter(Product.unit > 0)
    elif estado == 'agotado':
        query = query.filter(Product.unit == 0)
    products = query.all()
    categories = db.session.query(Product.category).distinct().filter(Product.category.isnot(None)).all()
    categories = [cat[0] for cat in categories]
    return render_template('inventory.html', products=products, categories=categories, estado=estado)

@app.route('/api/products')
def api_products():
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    estado = request.args.get('estado', '')
    query = Product.query
    if search:
        query = query.filter(
            or_(
                Product.name.contains(search),
                Product.code.contains(search),
                Product.description.contains(search)
            )
        )
    if category:
        query = query.filter(Product.category == category)
    if estado == 'disponible':
        query = query.filter(Product.unit > 0)
    elif estado == 'agotado':
        query = query.filter(Product.unit == 0)
    products = query.all()
    return jsonify([
        {
            'id': p.id,
            'name': p.name,
            'code': p.code,
            'description': p.description,
            'unit': p.unit,
            'category': p.category,
            'estado': 'Disponible' if p.unit > 0 else 'Agotado'
        } for p in products
    ])

@app.route('/delete_product/<int:product_id>', methods=['POST'])
def delete_product(product_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
    product = Product.query.get_or_404(product_id)
    db.session.delete(product)
    db.session.commit()
    flash('Producto eliminado exitosamente', 'success')
    return redirect(url_for('inventory'))

@app.route('/export_excel')
def export_excel():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    estado = request.args.get('estado', '')
    query = Product.query
    if search:
        query = query.filter(
            or_(
                Product.name.contains(search),
                Product.code.contains(search),
                Product.description.contains(search)
            )
        )
    if category:
        query = query.filter(Product.category == category)
    if estado == 'disponible':
        query = query.filter(Product.unit > 0)
    elif estado == 'agotado':
        query = query.filter(Product.unit == 0)
    products = query.all()
    data = [{
        'Nombre': p.name,
        'Código': p.code,
        'Descripción': p.description,
        'Categoría': p.category,
        'Cantidad': p.unit,
        'Estado': 'Disponible' if p.unit > 0 else 'Agotado'
    } for p in products]
    df = pd.DataFrame(data)
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
        df.to_excel(writer, index=False, sheet_name='Inventario')
    output.seek(0)
    return send_file(output, download_name='inventario.xlsx', as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000) 