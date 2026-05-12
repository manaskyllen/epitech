import torch.nn as nn
from torchvision import models


class MultiHead(nn.Module):
    def __init__(
        self,
        n_gender: int,
        n_subtype: int,
        n_type: int,
        n_season: int,
        n_material: int,
        n_colors: int,
        *,
        pretrained_backbone: bool = False,
    ):
        super().__init__()
        weights = models.ResNet18_Weights.DEFAULT if pretrained_backbone else None
        self.backbone = models.resnet18(weights=weights)
        in_features = self.backbone.fc.in_features
        self.backbone.fc = nn.Identity()

        self.head_gender = nn.Linear(in_features, n_gender)
        self.head_subtype = nn.Linear(in_features, n_subtype)
        self.head_type = nn.Linear(in_features, n_type)
        self.head_season = nn.Linear(in_features, n_season)
        self.head_material = nn.Linear(in_features, n_material)
        self.head_colors = nn.Linear(in_features, n_colors)

    def forward(self, x):
        features = self.backbone(x)
        return {
            "gender": self.head_gender(features),
            "item_subtype": self.head_subtype(features),
            "item_type": self.head_type(features),
            "season": self.head_season(features),
            "material": self.head_material(features),
            "colors": self.head_colors(features),
        }
