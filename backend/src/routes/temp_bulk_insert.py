"""
Simple API endpoint to bulk insert heatmap data
Add to main.py temporarily
"""
from fastapi import APIRouter
from pydantic import BaseModel
from database import SessionLocal
from sqlalchemy import text

router = APIRouter()

class BulkInsertRequest(BaseModel):
    data: list[tuple[str, float]]

@router.post("/bulk-insert-heatmap")
def bulk_insert_heatmap():
    """Insert 75 heatmap points for testing"""
    db = SessionLocal()
    try:
        # Delete existing
        db.execute(text("DELETE FROM resultado_queries_auxiliares WHERE id_query = 1"))
        
        # Insert all points
        data = [
            ('INST011',0.95),('INST012',0.92),('INST013',0.88),('INST014',0.91),
            ('INST015',0.87),('INST016',0.90),('INST017',0.86),('INST018',0.93),
            ('INST019',0.89),('INST020',0.85),('INST021',0.94),('INST022',0.88),
            ('INST023',0.91),('INST024',0.87),('INST025',0.92),('INST026',0.86),
            ('INST027',0.90),('INST028',0.84),('INST029',0.89),('INST030',0.93),
            ('INST031',0.88),('INST032',0.85),('INST033',0.91),('INST034',0.87),
            ('INST035',0.90),('INST036',0.86),('INST037',0.92),('INST038',0.89),
            ('INST039',0.85),('INST040',0.88),('INST041',0.72),('INST042',0.68),
            ('INST043',0.75),('INST044',0.70),('INST045',0.73),('INST046',0.69),
            ('INST047',0.74),('INST048',0.71),('INST049',0.76),('INST050',0.72),
            ('INST051',0.68),('INST052',0.75),('INST053',0.70),('INST054',0.73),
            ('INST055',0.69),('INST056',0.74),('INST057',0.71),('INST058',0.76),
            ('INST059',0.72),('INST060',0.68),('INST061',0.98),('INST062',0.95),
            ('INST063',0.91),('INST064',0.94),('INST065',0.90),('INST066',0.96),
            ('INST067',0.92),('INST068',0.89),('INST069',0.97),('INST070',0.93),
            ('INST071',0.88),('INST072',0.95),('INST073',0.91),('INST074',0.94),
            ('INST075',0.90),('INST076',0.65),('INST077',0.62),('INST078',0.68),
            ('INST079',0.64),('INST080',0.70),('INST081',0.66),('INST082',0.63),
            ('INST083',0.69),('INST084',0.65),('INST085',0.67)
        ]
        
        for inst_id, intensidade in data:
            db.execute(
                text("INSERT INTO resultado_queries_auxiliares (id_query, id_instalacao, intensidade) VALUES (1, :inst, :intens)"),
                {"inst": inst_id, "intens": intensidade}
            )
        
        db.commit()
        return {"success": True, "inserted": len(data)}
    except Exception as e:
        db.rollback()
        return {"success": False, "error": str(e)}
    finally:
        db.close()
