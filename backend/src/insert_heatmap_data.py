"""
Quick script to insert heatmap data for testing
Run with: python insert_heatmap_data.py
"""
import sys
sys.path.insert(0, 'C:/Users/eduar/Desktop/SASI/backend/src')

from database import engine
from sqlalchemy import text

# Heatmap data
heatmap_data = [
    # Natal region - high density
    ('INST011', 0.92), ('INST012', 0.88), ('INST013', 0.85), ('INST014', 0.91),
    ('INST015', 0.87), ('INST016', 0.84), ('INST017', 0.90), ('INST018', 0.86),
    ('INST019', 0.89), ('INST020', 0.83), ('INST021', 0.92), ('INST022', 0.88),
    ('INST023', 0.85), ('INST024', 0.91), ('INST025', 0.87), ('INST026', 0.84),
    ('INST027', 0.90), ('INST028', 0.86), ('INST029', 0.89), ('INST030', 0.83),
    ('INST031', 0.92), ('INST032', 0.88), ('INST033', 0.85), ('INST034', 0.91),
    ('INST035', 0.87), ('INST036', 0.84), ('INST037', 0.90), ('INST038', 0.86),
    ('INST039', 0.89), ('INST040', 0.83),
    # Mossoró
    ('INST041', 0.72), ('INST042', 0.68), ('INST043', 0.75), ('INST044', 0.70),
    ('INST045', 0.73), ('INST046', 0.69), ('INST047', 0.74), ('INST048', 0.71),
    ('INST049', 0.76), ('INST050', 0.72),
    # Parnamirim
    ('INST061', 0.95), ('INST062', 0.88), ('INST063', 0.91), ('INST064', 0.87),
    ('INST065', 0.93), ('INST066', 0.89), ('INST067', 0.86), ('INST068', 0.92),
]

with engine.connect() as conn:
    # Insert for query 1 (Densidade Populacional - heatmap)
    for inst_id, intensidade in heatmap_data:
        conn.execute(
            text("""
                INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade)
                VALUES (1, :inst_id, :intensidade)
                ON CONFLICT DO NOTHING
            """),
            {"inst_id": inst_id, "intensidade": intensidade}
        )
    
    conn.commit()
    print(f"✅ Inserted {len(heatmap_data)} heatmap points for query 1")
