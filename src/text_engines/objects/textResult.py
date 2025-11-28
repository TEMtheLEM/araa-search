from dataclasses import dataclass, field


# Provided as a 'blueprint' for a singular result from the text engine.
@dataclass
class TextResult:
    title: str
    desc: str
    url: str
    sublinks: list[str] = field(default_factory=list)

    def asDICT(self):
        return {
            "title": self.title,
            "desc": self.desc,
            "url": self.url,
            "sublinks": self.sublinks,
            "sublinks.len": len(self.sublinks),
        }
